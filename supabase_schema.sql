-- Social Voice App - Supabase PostgreSQL Schema
-- Migration from Firebase to Supabase
-- Date: 2026-01-20

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT,
    email TEXT UNIQUE,
    phone TEXT UNIQUE,
    photo_url TEXT,
    date_of_birth TIMESTAMPTZ,
    is_verified BOOLEAN DEFAULT FALSE,
    coins INTEGER DEFAULT 0 CHECK (coins >= 0),
    level INTEGER DEFAULT 1 CHECK (level >= 1 AND level <= 5),
    vip_until TIMESTAMPTZ,
    lifetime_gifts_value INTEGER DEFAULT 0,
    monthly_gifts_value INTEGER DEFAULT 0,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    blocked_users UUID[] DEFAULT '{}',
    report_count INTEGER DEFAULT 0,
    is_banned BOOLEAN DEFAULT FALSE,
    ban_reason TEXT,
    ban_expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for users table
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_level ON users(level);
CREATE INDEX idx_users_is_banned ON users(is_banned);
CREATE INDEX idx_users_created_at ON users(created_at);

-- ============================================
-- ROOMS TABLE
-- ============================================
CREATE TABLE rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    tags TEXT[] DEFAULT '{}',
    room_type TEXT DEFAULT 'public' CHECK (room_type IN ('public', 'private', 'friends_only')),
    status TEXT DEFAULT 'live' CHECK (status IN ('live', 'ended')),
    max_speakers INTEGER DEFAULT 20,
    total_listeners INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ
);

-- Indexes for rooms
CREATE INDEX idx_rooms_owner ON rooms(owner_id);
CREATE INDEX idx_rooms_status ON rooms(status);
CREATE INDEX idx_rooms_category ON rooms(category);
CREATE INDEX idx_rooms_created_at ON rooms(created_at);
CREATE INDEX idx_rooms_live ON rooms(status) WHERE status = 'live';

-- ============================================
-- ROOM PARTICIPANTS TABLE (Historical)
-- ============================================
CREATE TABLE room_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'audience' CHECK (role IN ('owner', 'admin', 'speaker', 'audience')),
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    left_at TIMESTAMPTZ,
    total_time_seconds INTEGER DEFAULT 0
);

-- Indexes
CREATE INDEX idx_room_participants_room ON room_participants(room_id);
CREATE INDEX idx_room_participants_user ON room_participants(user_id);

-- ============================================
-- LIVE ROOM PARTICIPANTS TABLE (Real-time state)
-- Enable Realtime subscriptions on this table
-- ============================================
CREATE TABLE live_room_participants (
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'audience' CHECK (role IN ('owner', 'admin', 'speaker', 'audience')),
    is_muted BOOLEAN DEFAULT FALSE,
    is_online BOOLEAN DEFAULT TRUE,
    network_quality TEXT DEFAULT 'good' CHECK (network_quality IN ('excellent', 'good', 'poor')),
    last_seen TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (room_id, user_id)
);

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE live_room_participants;

-- Indexes
CREATE INDEX idx_live_participants_room ON live_room_participants(room_id);
CREATE INDEX idx_live_participants_user ON live_room_participants(user_id);

-- ============================================
-- SPEAKER REQUESTS TABLE
-- ============================================
CREATE TABLE speaker_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    reviewed_at TIMESTAMPTZ,
    reviewed_by UUID REFERENCES users(id)
);

-- Indexes
CREATE INDEX idx_speaker_requests_room ON speaker_requests(room_id);
CREATE INDEX idx_speaker_requests_status ON speaker_requests(status);

-- ============================================
-- ROOM MESSAGES TABLE
-- ============================================
CREATE TABLE room_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_room_messages_room ON room_messages(room_id);
CREATE INDEX idx_room_messages_created_at ON room_messages(created_at);

-- ============================================
-- FOLLOWS TABLE
-- ============================================
CREATE TABLE follows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(follower_id, following_id),
    CHECK (follower_id != following_id)
);

-- Indexes
CREATE INDEX idx_follows_follower ON follows(follower_id);
CREATE INDEX idx_follows_following ON follows(following_id);

-- ============================================
-- TRANSACTIONS TABLE
-- ============================================
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('purchase', 'gift_sent', 'gift_received', 'reward', 'refund')),
    amount INTEGER NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);

-- ============================================
-- GIFTS TABLE (Catalog)
-- ============================================
CREATE TABLE gifts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    coin_value INTEGER NOT NULL CHECK (coin_value > 0),
    animation_url TEXT,
    thumbnail_url TEXT,
    category TEXT DEFAULT 'standard',
    is_active BOOLEAN DEFAULT TRUE,
    min_level_required INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_gifts_category ON gifts(category);
CREATE INDEX idx_gifts_active ON gifts(is_active) WHERE is_active = TRUE;

-- ============================================
-- ROOM GIFTS TABLE (Sent gifts for animations)
-- Enable Realtime for gift animations
-- ============================================
CREATE TABLE room_gifts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    gift_id UUID NOT NULL REFERENCES gifts(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE room_gifts;

-- Indexes
CREATE INDEX idx_room_gifts_room ON room_gifts(room_id);
CREATE INDEX idx_room_gifts_sender ON room_gifts(sender_id);
CREATE INDEX idx_room_gifts_receiver ON room_gifts(receiver_id);

-- ============================================
-- VIP SUBSCRIPTIONS TABLE
-- ============================================
CREATE TABLE vip_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    tier TEXT DEFAULT 'basic' CHECK (tier IN ('basic', 'premium')),
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMPTZ,
    revenue_cat_subscription_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_vip_subscriptions_user ON vip_subscriptions(user_id);
CREATE INDEX idx_vip_subscriptions_active ON vip_subscriptions(is_active);

-- ============================================
-- REPORTS TABLE
-- ============================================
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reported_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    room_id UUID REFERENCES rooms(id) ON DELETE SET NULL,
    reason TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'actioned', 'dismissed')),
    reviewed_by UUID REFERENCES users(id),
    action_taken TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    reviewed_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_reports_reporter ON reports(reporter_id);
CREATE INDEX idx_reports_reported_user ON reports(reported_user_id);
CREATE INDEX idx_reports_status ON reports(status);

-- ============================================
-- LEADERBOARD TABLE
-- ============================================
CREATE TABLE leaderboard (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category TEXT NOT NULL CHECK (category IN ('gifter', 'receiver', 'speaker', 'rising_star')),
    value INTEGER NOT NULL,
    rank INTEGER NOT NULL,
    period TEXT NOT NULL CHECK (period IN ('weekly', 'monthly', 'all_time')),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, category, period)
);

-- Indexes
CREATE INDEX idx_leaderboard_category_period ON leaderboard(category, period, rank);
CREATE INDEX idx_leaderboard_user ON leaderboard(user_id);

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- ============================================
-- ANALYTICS EVENTS TABLE
-- ============================================
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_name TEXT NOT NULL,
    properties JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_analytics_user ON analytics_events(user_id);
CREATE INDEX idx_analytics_event_name ON analytics_events(event_name);
CREATE INDEX idx_analytics_created_at ON analytics_events(created_at);
-- Partitioning by month recommended for large-scale analytics

-- ============================================
-- ADMINS TABLE
-- ============================================
CREATE TABLE admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('super_admin', 'moderator', 'support')),
    permissions TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- Indexes
CREATE INDEX idx_admins_user ON admins(user_id);
CREATE INDEX idx_admins_role ON admins(role);

-- ============================================
-- ADMIN LOGS TABLE (Audit trail)
-- ============================================
CREATE TABLE admin_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    target_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    reason TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_admin_logs_admin ON admin_logs(admin_id);
CREATE INDEX idx_admin_logs_action ON admin_logs(action);
CREATE INDEX idx_admin_logs_created_at ON admin_logs(created_at);

-- ============================================
-- TRIGGERS
-- ============================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Update follower counts
CREATE OR REPLACE FUNCTION update_follower_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE users SET followers_count = followers_count + 1 WHERE id = NEW.following_id;
        UPDATE users SET following_count = following_count + 1 WHERE id = NEW.follower_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE users SET followers_count = followers_count - 1 WHERE id = OLD.following_id;
        UPDATE users SET following_count = following_count - 1 WHERE id = OLD.follower_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_follower_counts_trigger
    AFTER INSERT OR DELETE ON follows
    FOR EACH ROW
    EXECUTE FUNCTION update_follower_counts();

-- Auto-ban users with 10+ reports
CREATE OR REPLACE FUNCTION check_auto_ban()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.report_count >= 10 AND NEW.is_banned = FALSE THEN
        UPDATE users 
        SET is_banned = TRUE, 
            ban_reason = 'Automatic ban - 10+ reports',
            ban_expires_at = NOW() + INTERVAL '24 hours'
        WHERE id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_ban_trigger
    AFTER UPDATE OF report_count ON users
    FOR EACH ROW
    EXECUTE FUNCTION check_auto_ban();

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_room_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE speaker_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_gifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE vip_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users: Can read all, update own
CREATE POLICY "Users can view all profiles" ON users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON users FOR INSERT WITH CHECK (auth.uid() = id);

-- Rooms: Public read, owner write
CREATE POLICY "Rooms are viewable by everyone" ON rooms FOR SELECT USING (true);
CREATE POLICY "Users can create rooms" ON rooms FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "Owners can update their rooms" ON rooms FOR UPDATE USING (auth.uid() = owner_id);

-- Follows: Users can manage their own follows
CREATE POLICY "Users can view follows" ON follows FOR SELECT USING (true);
CREATE POLICY "Users can create follows" ON follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Users can delete own follows" ON follows FOR DELETE USING (auth.uid() = follower_id);

-- Transactions: Users can view own transactions
CREATE POLICY "Users can view own transactions" ON transactions FOR SELECT USING (auth.uid() = user_id);

-- Notifications: Users can view own notifications
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);

-- Reports: Users can create reports
CREATE POLICY "Users can create reports" ON reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY "Users can view own reports" ON reports FOR SELECT USING (auth.uid() = reporter_id);

-- Room messages: Users can read messages in rooms they're in
CREATE POLICY "Users can view room messages" ON room_messages FOR SELECT USING (true);
CREATE POLICY "Users can create room messages" ON room_messages FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Room participants: Historical records
CREATE POLICY "Users can view room participants" ON room_participants FOR SELECT USING (true);
CREATE POLICY "Users can create own participation" ON room_participants FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own participation" ON room_participants FOR UPDATE USING (auth.uid() = user_id);

-- Live participants: Real-time access
CREATE POLICY "Users can view live participants" ON live_room_participants FOR SELECT USING (true);
CREATE POLICY "Users can manage own participation" ON live_room_participants 
    FOR ALL USING (auth.uid() = user_id);

-- Speaker requests
CREATE POLICY "Users can view speaker requests in their rooms" ON speaker_requests FOR SELECT USING (true);
CREATE POLICY "Users can create speaker requests" ON speaker_requests FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Room gifts: Viewable by everyone in room
CREATE POLICY "Users can view room gifts" ON room_gifts FOR SELECT USING (true);

-- ============================================
-- FUNCTIONS FOR COMMON OPERATIONS
-- ============================================

-- Function to process gift transaction
CREATE OR REPLACE FUNCTION process_gift_transaction(
    p_sender_id UUID,
    p_receiver_id UUID,
    p_gift_id UUID,
    p_room_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_gift_value INTEGER;
    v_sender_coins INTEGER;
    v_receiver_amount INTEGER;
    v_platform_fee INTEGER;
BEGIN
    -- Get gift value
    SELECT coin_value INTO v_gift_value FROM gifts WHERE id = p_gift_id;
    
    -- Check sender has enough coins
    SELECT coins INTO v_sender_coins FROM users WHERE id = p_sender_id;
    IF v_sender_coins < v_gift_value THEN
        RAISE EXCEPTION 'Insufficient coins';
    END IF;
    
    -- Calculate amounts (70% to receiver, 30% platform fee)
    v_receiver_amount := FLOOR(v_gift_value * 0.7);
    v_platform_fee := v_gift_value - v_receiver_amount;
    
    -- Deduct from sender
    UPDATE users SET coins = coins - v_gift_value WHERE id = p_sender_id;
    
    -- Add to receiver
    UPDATE users 
    SET coins = coins + v_receiver_amount,
        lifetime_gifts_value = lifetime_gifts_value + v_gift_value,
        monthly_gifts_value = monthly_gifts_value + v_gift_value
    WHERE id = p_receiver_id;
    
    -- Record transactions
    INSERT INTO transactions (user_id, type, amount, metadata)
    VALUES 
        (p_sender_id, 'gift_sent', -v_gift_value, jsonb_build_object('gift_id', p_gift_id, 'receiver_id', p_receiver_id, 'room_id', p_room_id)),
        (p_receiver_id, 'gift_received', v_receiver_amount, jsonb_build_object('gift_id', p_gift_id, 'sender_id', p_sender_id, 'room_id', p_room_id));
    
    -- Add to room gifts for animation
    INSERT INTO room_gifts (room_id, sender_id, receiver_id, gift_id)
    VALUES (p_room_id, p_sender_id, p_receiver_id, p_gift_id);
    
    RETURN json_build_object(
        'success', true,
        'sender_new_balance', (SELECT coins FROM users WHERE id = p_sender_id),
        'receiver_new_balance', (SELECT coins FROM users WHERE id = p_receiver_id)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- SEED DATA (Optional - for development)
-- ============================================

-- Insert some default gifts
INSERT INTO gifts (name, description, coin_value, category) VALUES
    ('Rose', 'A beautiful rose', 10, 'standard'),
    ('Heart', 'Show some love', 25, 'standard'),
    ('Diamond', 'Precious gift', 50, 'premium'),
    ('Lion', 'King of the jungle', 500, 'premium'),
    ('Rocket', 'To the moon!', 2000, 'legendary');

-- ============================================
-- NOTES FOR MIGRATION
-- ============================================

/*
1. Enable Realtime on tables:
   - Go to Supabase Dashboard > Database > Replication
   - Enable for: live_room_participants, room_gifts

2. Set up scheduled jobs with pg_cron:
   - Reset monthly_gifts_value (1st of each month)
   - Generate leaderboards (daily)
   - Cleanup old analytics events (monthly)

3. Configure Auth providers in Supabase Dashboard:
   - Phone (Twilio integration)
   - Google OAuth
   - Email/Password

4. Set up Storage buckets:
   - avatars (for profile photos)
   - room-backgrounds
   - gift-animations

5. Edge Functions to create:
   - generate-zego-token
   - revenuecat-webhook
   - moderate-content
   - cleanup-inactive-rooms
*/
