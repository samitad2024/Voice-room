-- Check all tables exist in your Supabase database
-- Copy this query and run it in Supabase SQL Editor
-- Dashboard > SQL Editor > New Query

-- List all tables that should exist
SELECT 
    schemaname,
    tablename,
    CASE 
        WHEN tablename IN (
            'users', 'rooms', 'room_participants', 'live_room_participants',
            'speaker_requests', 'room_messages', 'follows', 'transactions',
            'gifts', 'room_gifts', 'vip_subscriptions', 'reports',
            'leaderboard', 'notifications', 'analytics_events', 'admins', 'admin_logs'
        ) THEN '✓ Expected table'
        ELSE '? Unknown table'
    END as status
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- Count rows in each table (to see if they're populated)
SELECT 
    'users' as table_name, COUNT(*) as row_count FROM users
UNION ALL SELECT 'rooms', COUNT(*) FROM rooms
UNION ALL SELECT 'room_participants', COUNT(*) FROM room_participants
UNION ALL SELECT 'live_room_participants', COUNT(*) FROM live_room_participants
UNION ALL SELECT 'speaker_requests', COUNT(*) FROM speaker_requests
UNION ALL SELECT 'room_messages', COUNT(*) FROM room_messages
UNION ALL SELECT 'follows', COUNT(*) FROM follows
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL SELECT 'gifts', COUNT(*) FROM gifts
UNION ALL SELECT 'room_gifts', COUNT(*) FROM room_gifts
UNION ALL SELECT 'vip_subscriptions', COUNT(*) FROM vip_subscriptions
UNION ALL SELECT 'reports', COUNT(*) FROM reports
UNION ALL SELECT 'leaderboard', COUNT(*) FROM leaderboard
UNION ALL SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL SELECT 'analytics_events', COUNT(*) FROM analytics_events
UNION ALL SELECT 'admins', COUNT(*) FROM admins
UNION ALL SELECT 'admin_logs', COUNT(*) FROM admin_logs;

-- Check which tables have RLS enabled
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- Check Realtime is enabled for the correct tables
SELECT 
    schemaname,
    tablename,
    CASE 
        WHEN tablename IN ('live_room_participants', 'room_gifts') 
        THEN '✓ Should have Realtime'
        ELSE 'No Realtime needed'
    END as realtime_status
FROM pg_tables 
WHERE schemaname = 'public' 
    AND tablename IN ('live_room_participants', 'room_gifts')
ORDER BY tablename;
