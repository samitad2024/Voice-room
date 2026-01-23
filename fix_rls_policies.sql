-- Fix Row Level Security policies for room_participants and live_room_participants
-- Run this in Supabase SQL Editor

-- Add missing RLS policies for room_participants
CREATE POLICY "Users can view room participants" ON room_participants FOR SELECT USING (true);
CREATE POLICY "Users can create own participation" ON room_participants FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own participation" ON room_participants FOR UPDATE USING (auth.uid() = user_id);

-- Verify the policies are created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('room_participants', 'live_room_participants')
ORDER BY tablename, policyname;
