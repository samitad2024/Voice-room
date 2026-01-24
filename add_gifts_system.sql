-- Gifts table: catalog of available gifts
CREATE TABLE IF NOT EXISTS gifts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    image_url TEXT NOT NULL,
    coin_cost INTEGER NOT NULL CHECK (coin_cost > 0),
    category VARCHAR(20) DEFAULT 'basic' CHECK (category IN ('basic', 'premium', 'exclusive')),
    animation_type VARCHAR(20) DEFAULT 'simple' CHECK (animation_type IN ('simple', 'confetti', 'fullscreen')),
    min_level INTEGER DEFAULT 0 CHECK (min_level >= 0),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default gifts
INSERT INTO gifts (name, image_url, coin_cost, category, animation_type, min_level) VALUES
('Rose', 'https://placehold.co/100x100/FF69B4/white?text=🌹', 10, 'basic', 'simple', 0),
('Heart', 'https://placehold.co/100x100/FF0000/white?text=❤️', 20, 'basic', 'simple', 0),
('Cake', 'https://placehold.co/100x100/FFA07A/white?text=🎂', 50, 'basic', 'confetti', 0),
('Diamond', 'https://placehold.co/100x100/00CED1/white?text=💎', 100, 'premium', 'confetti', 1),
('Crown', 'https://placehold.co/100x100/FFD700/white?text=👑', 200, 'premium', 'confetti', 2),
('Lion', 'https://placehold.co/100x100/FF8C00/white?text=🦁', 500, 'premium', 'fullscreen', 3),
('Rocket', 'https://placehold.co/100x100/1E90FF/white?text=🚀', 1000, 'exclusive', 'fullscreen', 4),
('Trophy', 'https://placehold.co/100x100/FFD700/white?text=🏆', 2000, 'exclusive', 'fullscreen', 5);

-- Enable RLS
ALTER TABLE gifts ENABLE ROW LEVEL SECURITY;

-- RLS policies for gifts
CREATE POLICY "Anyone can view active gifts" ON gifts FOR SELECT USING (is_active = true);

-- Update room_gifts table if needed (should already exist from schema)
ALTER TABLE room_gifts ADD COLUMN IF NOT EXISTS coin_value INTEGER;

-- PostgreSQL function to send gift with transaction safety
CREATE OR REPLACE FUNCTION send_gift(
    p_room_id UUID,
    p_sender_id UUID,
    p_receiver_id UUID,
    p_gift_id UUID
) RETURNS JSON AS $$
DECLARE
    v_gift_cost INTEGER;
    v_sender_coins INTEGER;
    v_platform_fee NUMERIC := 0.30; -- 30% platform fee
    v_receiver_amount INTEGER;
    v_gift_record UUID;
BEGIN
    -- Get gift cost
    SELECT coin_cost INTO v_gift_cost
    FROM gifts
    WHERE id = p_gift_id AND is_active = true;
    
    IF v_gift_cost IS NULL THEN
        RAISE EXCEPTION 'Gift not found or inactive';
    END IF;
    
    -- Get sender's coin balance
    SELECT coins INTO v_sender_coins
    FROM users
    WHERE id = p_sender_id;
    
    -- Check if sender has enough coins
    IF v_sender_coins < v_gift_cost THEN
        RAISE EXCEPTION 'Insufficient coins. You have % coins but need %', v_sender_coins, v_gift_cost;
    END IF;
    
    -- Calculate receiver amount after platform fee
    v_receiver_amount := FLOOR(v_gift_cost * (1 - v_platform_fee));
    
    -- Start transaction
    -- 1. Deduct coins from sender
    UPDATE users
    SET coins = coins - v_gift_cost,
        updated_at = NOW()
    WHERE id = p_sender_id;
    
    -- 2. Add coins to receiver (after platform cut)
    UPDATE users
    SET coins = coins + v_receiver_amount,
        lifetime_gifts_value = lifetime_gifts_value + v_gift_cost,
        monthly_gifts_value = monthly_gifts_value + v_gift_cost,
        updated_at = NOW()
    WHERE id = p_receiver_id;
    
    -- 3. Create room gift record
    INSERT INTO room_gifts (room_id, sender_id, receiver_id, gift_id, coin_value)
    VALUES (p_room_id, p_sender_id, p_receiver_id, p_gift_id, v_gift_cost)
    RETURNING id INTO v_gift_record;
    
    -- 4. Create transaction records
    INSERT INTO transactions (user_id, type, amount, metadata)
    VALUES 
        (p_sender_id, 'gift_sent', -v_gift_cost, json_build_object('gift_id', p_gift_id, 'receiver_id', p_receiver_id, 'room_id', p_room_id)),
        (p_receiver_id, 'gift_received', v_receiver_amount, json_build_object('gift_id', p_gift_id, 'sender_id', p_sender_id, 'room_id', p_room_id, 'original_value', v_gift_cost));
    
    -- Return success with gift ID
    RETURN json_build_object(
        'success', true,
        'gift_id', v_gift_record,
        'coins_spent', v_gift_cost,
        'coins_received', v_receiver_amount
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_gifts_active ON gifts(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_gifts_category ON gifts(category);
CREATE INDEX IF NOT EXISTS idx_room_gifts_room_created ON room_gifts(room_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_room_gifts_receiver ON room_gifts(receiver_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_room_gifts_sender ON room_gifts(sender_id, created_at DESC);

-- Enable realtime for room_gifts (for live gift animations)
ALTER PUBLICATION supabase_realtime ADD TABLE room_gifts;
