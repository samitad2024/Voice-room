# Social Audio Mobile App Blueprint – Detailed Version (Voice Rooms like Ludo Club / Yalla style)

Architecture: Flutter 3.24+ • Clean Architecture • BLoC • Supabase • ZegoCloud (voice) • RevenueCat (IAP)

## Project Goal
Voice-first social app (NOT game). Users create/join live voice chat rooms with roles, moderation, real-time gifting, coins economy, VIP/Legend levels, profiles & social features.

## Core Tech Stack & Decisions (2026 best practices)
- Flutter + dart 3.5+
- State: flutter_bloc (Bloc for complex → Room/Wallet, Cubit for simple → Profile/Notifications)
- DI: get_it
- Voice: zego_express_engine ^3.16+ (audio-only mode) + zego_uikit_signaling_plugin (signaling if needed)
- IAP & Coins: purchases_flutter (RevenueCat) → webhooks → Edge Functions → PostgreSQL
- Backend: Supabase (Auth, PostgreSQL Database with Row Level Security, **Realtime subscriptions for live room state**, Edge Functions, Storage)
- Models: freezed + json_serializable
- Error handling: dartz → Either<Failure, T>
- Utils: equatable, intl, uuid, cached_network_image, permission_handler, shimmer, badges, connectivity_plus, url_launcher, share_plus
- Analytics: supabase_analytics + custom events (or PostHog integration)

### Zego Configuration Details
- **Token Generation**: Server-side via Supabase Edge Functions (never expose AppSign in client)
- **Audio Settings**: 
  - Bitrate: 48kbps (standard quality) / 96kbps (high quality for VIP)
  - Codec: Opus (best for voice)
  - Noise suppression: ON
  - Echo cancellation: ON
  - Auto gain control: ON
- **Room Capacity**: Max 20 speakers + unlimited listeners (Zego limit: 500 concurrent users per room)
- **Reconnection Strategy**: Auto-reconnect with exponential backoff (1s, 2s, 4s, 8s max)
- **Background Audio**: Enable audio session to continue when app minimized (iOS/Android)

### Real-time Data Strategy
- **PostgreSQL Tables**: Static room metadata, user profiles, coins, transactions, chat history (with proper indexing)
- **Supabase Realtime**: Active room state (participants, mute status, speaking indicators, presence)
  - Table: `live_room_participants` with real-time subscriptions
  - Columns: room_id, user_id, role, is_muted, joined_at, is_online, last_seen, network_quality
  - Efficient real-time updates via PostgreSQL's LISTEN/NOTIFY + Row Level Security
- **Zego Signaling**: Real-time commands (mute, kick, role change) for instant delivery

---

## Design System & Color Theme

### Color Palette
Modern UI with **blue, white and subtle green accents**, supporting **light and dark mode**

#### Light Mode
- **Primary Blue**: `#2196F3` (buttons, active states, links)
- **Primary Dark**: `#1976D2` (hover states, emphasis)
- **Accent Green**: `#4CAF50` (success, online status, positive actions)
- **Background**: `#FFFFFF` (main background)
- **Surface**: `#F5F5F5` (cards, elevated surfaces)
- **Text Primary**: `#212121` (main text)
- **Text Secondary**: `#757575` (subtitles, metadata)
- **Divider**: `#E0E0E0`

#### Dark Mode
- **Primary Blue**: `#42A5F5` (buttons, active states, links)
- **Primary Dark**: `#1E88E5` (hover states, emphasis)
- **Accent Green**: `#66BB6A` (success, online status, positive actions)
- **Background**: `#121212` (main background)
- **Surface**: `#1E1E1E` (cards, elevated surfaces)
- **Surface Elevated**: `#2C2C2C` (modals, bottom sheets)
- **Text Primary**: `#FFFFFF` (main text)
- **Text Secondary**: `#B0B0B0` (subtitles, metadata)
- **Divider**: `#333333`

#### Status Colors (both modes)
- **Error/Muted**: `#F44336`
- **Warning**: `#FF9800`
- **Info**: `#2196F3`
- **Speaking Indicator**: `#4CAF50` (animated pulse)

### Typography
- **Font Family**: Inter / SF Pro (iOS) / Roboto (Android)
- **Headings**: Bold, 24-32sp
- **Body**: Regular, 14-16sp
- **Captions**: Medium, 12-14sp

### UI Components Style
- **Corner Radius**: 12dp (cards), 24dp (buttons), 50% (avatars)
- **Elevation**: Material Design 3 shadows
- **Icons**: Material Icons / SF Symbols
- **Animations**: 200-300ms ease-in-out transitions

### Key UI Elements
- **Room Cards**: White/surface background, blue accent for live indicator, green for online count
- **Gift Buttons**: Blue primary with subtle green shimmer on premium gifts
- **Level Frames**: Gradient overlays (bronze → silver → gold → platinum → diamond with blue/green tints)
- **Speaking Indicator**: Pulsing green ring around avatar
- **Muted Indicator**: Red slash icon overlay

---

## Folder Structure Reminder (feature-first clean arch)
lib/
├── app.dart                       # App widget + theme + BlocObserver
├── main.dart                      # Entry point + dependency injection setup
├── core/                          # App-wide shared things (NEVER feature-specific)
│   ├── constants/                 # colors, strings, api_keys, app_constants.dart
│   ├── error/                     # failures.dart, exceptions.dart
│   ├── network/                   # network_info.dart (connectivity_plus)
│   ├── usecases/                  # base_usecase.dart
│   ├── utils/                     # extensions.dart, helpers.dart, logger.dart
│   └── di/                        # injection_container.dart (get_it setup)
├── features/                      # Feature-based modules (recommended for scalability)
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/       # auth_remote_datasource.dart, auth_local_datasource.dart
│   │   │   ├── models/            # user_model.dart
│   │   │   └── repositories/      # auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/          # user_entity.dart
│   │   │   ├── repositories/      # auth_repository.dart (abstract)
│   │   │   └── usecases/         # login_usecase.dart, register_usecase.dart, get_current_user.dart, verify_age.dart
│   │   └── presentation/
│   │       ├── bloc/              # auth_bloc.dart, auth_event.dart, auth_state.dart
│   │       ├── pages/             # login_page.dart, register_page.dart, age_verification_page.dart
│   │       └── widgets/           # custom widgets for auth
│   ├── home/                      # Home / Dashboard (room list, discover, profile quick access)
│   ├── room/                      # Core → Voice Rooms (most complex feature)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/             # room_list_page.dart, create_room_page.dart, voice_room_page.dart
│   │       └── widgets/           # speaker_view.dart, audience_view.dart, gift_effect.dart, role_indicator.dart, network_quality_indicator.dart
│   ├── wallet/
│   ├── profile/
│   ├── gifts/
│   ├── vip_levels/
│   ├── notifications/
│   ├── moderation/                # Report, block, ban system
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── leaderboard/               # Top gifters, top receivers, weekly/monthly
│   ├── followers/                 # Social graph management
│   ├── settings/                  # App settings, privacy, account
│   └── analytics/                 # Event tracking wrapper
└── common/                        # Very shared across features (use sparingly!)
    ├── widgets/                   # app_button.dart, loading_indicator.dart, error_widget.dart, profile_avatar.dart
    └── models/                    # simple shared models (e.g. coin_transaction.dart if used everywhere)

## Detailed Features & User Flows

### 1. Authentication
Goal: Fast onboarding, phone preferred (common in social audio apps in Africa/Asia)

User Flows:
- Open app → Splash → If not logged in → Welcome screen (Login / Register)
- Phone login → Enter number → OTP (Supabase Auth with Twilio) → **Age verification (13+)** → Name + photo (optional) → Finish
- Google/Apple one-tap → Auto create profile (Supabase Social Auth) → Age verification
- After login → Home (room discovery)
- **Restore purchases** on first launch (RevenueCat)

Supabase: users table → {id (UUID), name, photo_url, phone, created_at, coins (default: 0), level (default: 1), vip_until, date_of_birth, is_verified, blocked_users (JSON array), report_count (default: 0)}

**Security**: 
- Age verification required (store hashed DOB)
- Email verification for sensitive actions (withdraw, account deletion)
- Device fingerprinting to prevent multi-account abuse
- Row Level Security (RLS) policies to ensure users only access their own data

### 2. User Profile
Goal: Show personality + social proof

User Flows:
- My Profile: Tap avatar (bottom nav) → See own level frame, coins, gifts received, followers/following count
- Edit profile: Change name, bio, photo (upload to Supabase Storage)
- Other user profile: Tap avatar in room/list → View name, level frame, bio, follow/unfollow button, total gifts received, legend level badge

Supabase: users table + received_gifts table (with foreign key to users for total value calculation via SQL aggregation)

BLoC: ProfileBloc → LoadProfile, UpdateProfile, FollowUser events

### 3. Home / Room Discovery (Main Feed)
Goal: Help users find interesting live rooms quickly

User Flows:
- Bottom nav: Home icon → Show list of live rooms (trending, categories, friends in rooms)
- Filters: All / Friends / Trending / New / Categories (Music, Talk, Dating, Fun, Education…)
- Search bar: by room title, owner name, tags (using PostgreSQL full-text search)
- Tap room card → Preview (title, owner, speakers count, listeners count, tags) → Join button

Supabase: rooms table – SQL query: `SELECT * FROM rooms WHERE status = 'live' ORDER BY created_at DESC, listeners_count DESC`
- Proper indexes on status, created_at, listeners_count for fast queries

### 4. Voice Rooms – Core Feature (Most Important!)
Goal: Real-time voice chat with roles & moderation (similar Ludo Club voice rooms + Yalla)

Roles:
- Owner (creator) → full control
- Super Admin (app global) → can moderate any room
- Admin (appointed by owner) → mute/kick/ban
- Speaker → can speak
- Audience → listen only + can request to speak

User Flows – Create Room:
1. Tap "+" (floating action) → Create Room screen
2. Enter title, topic/tags, type (Public / Private / Friends-only)
3. Choose category
4. Create → Generate UUID → Get Zego token (Edge Function) → Join as Owner/Speaker

User Flows – Join Room:
1. From home → tap room → Join → Audience by default
2. Zego engine init → join room → subscribe to userJoined/left events
3. UI: Top – owner + admins, Middle – speakers grid (up to 9–12 visible), Bottom – audience list (scrollable)

User Flows – Speaker Request & Moderation:
1. Audience → tap "Request to Speak" button → request inserted into speaker_requests table
2. Owner/Admin sees notification/badge (via Realtime subscription) → Approve/Reject
3. Approved → role change → become speaker (Zego start publishing stream)
4. Mute/Kick/Ban: Owner/Admin long-press user → choose action → update participant record + emit via Realtime broadcast

Supabase Structure:
**PostgreSQL Tables** (static data):
rooms table:
  - id (UUID), title, owner_id (FK to users), category, tags (text[]), created_at, status ('live'/'ended'), max_speakers (default: 20), total_listeners (default: 0)
  
room_participants table:
  - id (UUID), room_id (FK), user_id (FK), role, joined_at, total_time_in_room [historical record]
  
speaker_requests table:
  - id (UUID), room_id (FK), user_id (FK), status ('pending'/'approved'/'rejected'), created_at
  
room_messages table:
  - id (UUID), room_id (FK), user_id (FK), message, created_at
  
room_reports table:
  - id (UUID), room_id (FK), reporter_id (FK), reported_user_id (FK), reason, created_at

**Realtime Subscriptions** (live state):
live_room_participants table (with Realtime enabled):
  - room_id, user_id, role, is_muted, is_online, network_quality ('excellent'/'good'/'poor'), last_seen
  - Subscribe to changes: `supabase.from('live_room_participants').on('*', callback).subscribe()`
  
live_room_metadata table:
  - room_id (PK), active_listeners, active_speakers, updated_at

BLoC: RoomBloc (very complex)
- Events: CreateRoom, JoinRoom, LeaveRoom, RequestSpeak, ApproveRequest, MuteUser, KickUser, BanUser, SendTextMessage, ReportUser, UpdateNetworkQuality
- States: RoomLoading, RoomActive(roomData, participants, requests, networkQuality), RoomError, SpeakerGranted, Reconnecting, ZegoTokenExpired
- Uses Supabase Realtime subscriptions for live participant updates

**Network Quality Monitoring**:
- Zego SDK reports quality every 2s → update UI indicator
- Poor quality → show warning "Your connection is unstable"
- Auto-downgrade to lower bitrate if needed

### 5. Coins System + In-App Purchase
Goal: Main monetization – buy coins → send gifts → creators earn

User Flows:
- Wallet screen → See balance → Top-up button → RevenueCat offerings
  - **Coin Packs**: 100 ($0.99), 500 ($4.99), 2000 ($19.99), 10000 ($99.99)
  - **VIP Subscriptions**: Monthly ($9.99) → 1000 coins/month + benefits (no ads, priority support, special gifts, exclusive frames)
- Buy → RevenueCat purchase flow → success → Edge Function webhook → add coins to user record
- **Restore purchases** button (important for device changes)
- Transaction history list (buy, send gift, receive gift, level up reward, subscription renewal)

Supabase: 
- users table → coins (atomic increment via PostgreSQL transactions + RPC functions!)
- vip_subscriptions table: user_id (FK), is_active, tier ('basic'/'premium'), expires_at
- transactions table: id (UUID), user_id (FK), type ('purchase'/'gift_sent'/'gift_received'/'reward'), amount, created_at, metadata (JSONB)

**Revenue Model**:
- Coin purchases (primary)
- VIP subscriptions (recurring revenue)
- Platform fee on gifts: 30% (70% to creator)
- Ads for free users (optional – show between room switches)

### 6. Gifting System
Goal: Emotional support + monetization loop

User Flows:
- In room → tap gift icon (bottom bar) → gift tray opens
- Choose gift (rose=10 coins, lion=500, rocket=2000…) + target speaker/owner
- Send → deduct coins (PostgreSQL transaction) → show animation (full-screen for expensive gifts)
- Receiver gets notification + coins (after platform cut 30–50%)
- Gift appears in activity → "Samuel sent a Lion to @DJMax"

Supabase: room_gifts table (with Realtime enabled) for animation trigger
- Columns: id, room_id (FK), sender_id (FK), receiver_id (FK), gift_id, created_at
- Real-time subscription triggers animation on all clients in room

### 7. VIP & Legend Levels (1–5)
Goal: Status symbol + incentive to receive gifts

User Flows:
- Level based on total value of gifts received (monthly reset for fair competition)
- **Level 1**: 0–999 coins (Bronze frame)
- **Level 2**: 1k–4.9k (Silver frame)
- **Level 3**: 5k–19k (Gold frame)
- **Level 4**: 20k–99k (Platinum frame)
- **Level 5 (Legend)**: 100k+ (Diamond frame) → special animated frame, badge, priority in speaker requests, exclusive gifts access, custom room themes

UI: 
- Profile frame changes color/style per level + legend animation
- Level badge shown on avatar everywhere (rooms, profiles, leaderboard)
- Level-up celebration modal with confetti animation

Supabase: 
```sql
users table columns:
  lifetime_gifts_value: 245000 (never resets)
  monthly_gifts_value: 45000 (resets 1st of month via pg_cron extension)
  level: 3 (calculated from monthly_gifts_value via trigger or scheduled function)
  last_level_check: timestamp
```

**Level Benefits**:
- Level 3+: Priority in speaker requests queue
- Level 4+: Custom profile themes, exclusive gift access
- Level 5: Room creation limit increased (5 → 20 rooms), verified badge, featured on homepage

### 8. Wallet & Transactions
Goal: Transparency + trust

User Flows:
- Bottom nav Wallet → Balance big number
- History list (buy, send, receive, level reward)
- Withdraw? (future – not in v1)

### 9. Notifications
Goal: Re-engagement

Types:
- Someone followed you
- Gift received (with sender & gift name)
- Speaker request approved/rejected
- Room invite from friend
- Level up
- Moderation action (you were muted/kicked)

Supabase: 
- Push notifications via Firebase Cloud Messaging (FCM) or OneSignal integration
- notifications table for history: id, user_id (FK), type, title, body, data (JSONB), is_read, created_at
- Edge Function to send push notifications when events occur

### 10. Followers & Social Graph
Goal: Build community

User Flows:
- Follow/Unfollow from profile
- See followers/following list
- "Friends in room" filter on home
- Notification when followed
- Private rooms → invite followers only

Supabase: 
- follows table: id, follower_id (FK to users), following_id (FK to users), created_at
  - Unique constraint on (follower_id, following_id)
  - Indexes on both columns for fast queries
- users table → followers_count, following_count (updated via database triggers for consistency)

### 11. Moderation & Safety (NEW)
Goal: Safe environment + protect users from abuse

User Flows:
- **Report User**: Long-press avatar → Report → Choose reason (harassment, spam, inappropriate content, underage) → Submit → Cloud Function reviews
- **Block User**: Profile → Block → Hide all content from this user, prevent them from joining your rooms
- **Admin Tools** (for super admins):
  - Global ban (ban from all rooms)
  - Shadow ban (user thinks they're speaking but others don't hear)
  - View report history
  - Ban appeals review

Supabase:
```sql
reports table:
  id (UUID), reporter_id (FK), reported_user_id (FK), room_id (FK), 
  reason, description, created_at, status ('pending'/'reviewed'/'actioned'), 
  reviewed_by (FK to users), action_taken

users table columns:
  blocked_users (UUID[]) - array of user IDs
  report_count (default: 0, auto-ban at 10 via trigger)
  is_banned (default: false)
  ban_reason (text)
  ban_expires_at (timestamp, null = permanent)
```

**Auto-moderation**:
- 10+ reports → auto-ban for 24h + admin review
- Spam detection: >20 messages/min → auto-mute
- Profanity filter on room titles & messages

### 12. Leaderboard (NEW)
Goal: Gamification + showcase top users

User Flows:
- Leaderboard tab → See rankings:
  - **Top Gifters** (this week/month): Who sent most gifts
  - **Top Receivers** (this week/month): Who received most gifts
  - **Most Active Speakers** (total hours)
  - **Rising Stars** (new users with high engagement)
- Tap user → view profile

Supabase:
- Aggregated via pg_cron scheduled jobs or Edge Functions (run daily)
- leaderboard table: id, user_id (FK), category ('gifter'/'receiver'/'speaker'), value, rank, period ('weekly'/'monthly'), updated_at
- Use PostgreSQL window functions for efficient ranking calculations
- Materialized views for fast leaderboard queries

### 13. Deep Linking & Sharing (NEW)
Goal: Viral growth + easy room invites

User Flows:
- Share Room: Tap share icon → Generate link → `https://socialvoice.app/room/{roomId}` → Copy/share via WhatsApp, Twitter, etc.
- Receive link → Opens app (if installed) or landing page → Join room
- Share Profile: `https://socialvoice.app/user/{uid}`

Implementation:
- Firebase Dynamic Links or Branch.io
- Handle deep links in app → navigate to room/profile
- Track referrals → reward sharer with bonus coins

### 14. Background Audio (NEW)
Goal: Keep listening while multitasking

User Flows:
- User joins room → minimize app → audio continues
- Lock screen controls: play/pause (leave room), speaker name
- Picture-in-Picture (Android) → mini floating window

Implementation:
- iOS: AVAudioSession with `.playback` mode
- Android: Foreground service with notification
- Zego: Enable audio in background mode

### 15. Analytics & Events (NEW)
Goal: Data-driven decisions + understand user behavior

Key Events to Track:
- `app_open`, `login`, `register`
- `room_created`, `room_joined`, `room_left`, `time_in_room`
- `gift_sent` (gift type, value, receiver level)
- `speaker_request`, `speaker_approved`, `muted_by_admin`
- `coin_purchase` (amount, package)
- `vip_subscribed`, `vip_cancelled`
- `profile_viewed`, `user_followed`
- `report_submitted`, `user_blocked`

Supabase:
- analytics_events table for custom events: id, user_id (FK), event_name, properties (JSONB), created_at
- Use PostHog or Mixpanel integration for advanced analytics
- Create PostgreSQL views for real-time metrics dashboards
- Time-series data analysis using TimescaleDB extension (optional)

### 16. Admin Dashboard (NEW)
Goal: Manage platform, moderate content, monitor revenue, handle support

**Access Control**:
- Admin roles: `superAdmin`, `moderator`, `support`
- Stored in PostgreSQL: admins table → id (UUID), user_id (FK), role, permissions (text[]), created_at, created_by (FK)
- Separate web app (Flutter Web or React/Next.js)
- Auth: Supabase Auth with custom claims/metadata
- Row Level Security policies to restrict admin-only data
- URL: `https://admin.socialvoice.app`

#### Dashboard Sections

**1. Overview / Analytics**
- Real-time metrics:
  - Total users (active today, this week, this month)
  - Active rooms (live now)
  - Total revenue (today, this week, this month)
  - Pending reports count
  - New registrations (24h)
- Charts:
  - Daily active users (DAU) trend (last 30 days)
  - Revenue breakdown (coin purchases vs VIP subscriptions)
  - Top rooms by listeners
  - Peak hours heatmap

**2. User Management**
- **User List Table**:
  - Columns: Avatar, Name, UID, Email/Phone, Level, Coins, VIP Status, Join Date, Last Active, Status (active/banned), Actions
  - Filters: Search by name/UID, Level, VIP status, Banned, Date range
  - Pagination: 50 users per page
- **User Detail Modal**:
  - Profile info (name, photo, bio, level, badges)
  - Statistics: Total rooms joined, total gifts sent/received, followers/following count
  - Transaction history (last 50)
  - Reports received (count + details)
  - Ban history
- **Admin Actions**:
  - Ban user (temp: 1h, 24h, 7d, 30d | permanent) + reason
  - Unban user
  - Reset level/coins (with audit log)
  - Send push notification
  - View login history
  - Delete account (GDPR)

**3. Room Management**
- **Active Rooms Table**:
  - Columns: Room Title, Owner, Category, Listeners Count, Speakers Count, Duration, Created At, Actions
  - Real-time updates (Firestore listener)
  - Filters: Category, Date range, Min/max listeners
- **Room History** (ended rooms):
  - Search by title/owner
  - View room stats (total participants, duration, gifts sent)
  - Export data
- **Admin Actions**:
  - Join room as invisible moderator
  - Force end room
  - Ban room owner
  - View chat logs
  - Export room data

**4. Report Management (Priority)**
- **Reports Queue Table**:
  - Columns: Report ID, Reporter (avatar + name), Reported User (avatar + name), Reason, Room, Timestamp, Status (pending/reviewed/actioned), Assigned To, Actions
  - Sort by: Date (newest first), Status, Priority (auto-flagged users)
  - Filters: Status, Reason type, Date range
- **Report Detail Modal**:
  - Full context: Reporter info, reported user info, room context, reason, description
  - Evidence: Screenshots (if uploaded), chat logs, voice recording (if flagged)
  - Reported user history: Previous reports, ban history
  - Auto-suggestion: "User has 8 previous reports - recommend 7-day ban"
- **Admin Actions**:
  - Dismiss report (with reason)
  - Warn user (send notification)
  - Ban user (temp/permanent)
  - Ban from specific room only
  - Escalate to senior admin
  - Add to watch list
- **Auto-moderation Rules**:
  - 10+ reports → auto-ban 24h + flag for review
  - Banned user creates new account → auto-flag (device fingerprint)

**5. Transaction Management**
- **Transactions Table**:
  - Columns: TX ID, User, Type (purchase/gift_sent/gift_received/refund), Amount, Platform Fee, Status, Payment Method, Timestamp, Actions
  - Filters: Type, Date range, Amount range, Status (completed/pending/failed)
  - Export to CSV
- **Revenue Analytics**:
  - Total revenue (gross, net after platform fees)
  - Revenue by source (iOS, Android, Web)
  - Top spenders (whale analysis)
  - Refund rate
  - VIP subscription MRR (Monthly Recurring Revenue)
- **Admin Actions**:
  - Issue refund (with RevenueCat API)
  - View invoice
  - Investigate fraud
  - Adjust coins (manual correction with audit log)

**6. Gift Analytics**
- Most popular gifts (by count, by value)
- Gift economy flow (who sends to whom)
- Top gifters, top receivers
- Gift animation performance metrics

**7. Support Tickets (Optional)**
- User-submitted tickets
- Chat interface with users
- Ticket status (open/pending/resolved)
- Assign to support agents

**8. System Health**
- Zego API status + usage stats
- Firebase quota usage (Firestore reads/writes, Cloud Functions invocations)
- RevenueCat webhook status
- Error logs (Cloud Functions errors)
- Performance metrics (app crashes, ANR rate)

**9. Content Management**
- **Gift Catalog**: Add/edit/disable gifts, set prices, upload animations
- **Announcements**: Send in-app banners, push notifications to all users
- **Promotions**: Create coin sale events (e.g., "Double coins this weekend")
- **Featured Rooms**: Manually feature rooms on homepage

**10. Admin Logs (Audit Trail)**
- All admin actions logged: Who, What, When, Why
- Searchable by admin, action type, date
- Immutable records (append-only Firestore collection)

#### Tech Stack for Admin Dashboard
- **Frontend**: Flutter Web (share code with mobile) or Next.js + React
- **Backend**: Supabase Edge Functions + PostgreSQL
- **Auth**: Supabase Auth with custom claims/metadata (role-based)
- **Hosting**: Vercel, Netlify, or Supabase hosting
- **Real-time**: Supabase Realtime subscriptions for live data
- **Export**: Edge Functions or server-side queries to generate CSV/Excel reports

#### Security for Admin Dashboard
- IP whitelist (optional - only office IPs)
- 2FA required for superAdmin
- Session timeout: 1 hour
- All actions require password re-confirmation for sensitive operations
- Rate limiting on API calls

#### PostgreSQL Schema for Admin
```sql
admins table:
  id (UUID), user_id (FK), role ('superAdmin'/'moderator'/'support'), 
  permissions (text[]), created_at

admin_logs table:
  id (UUID), admin_id (FK), action, target_user_id (FK), 
  reason, created_at, metadata (JSONB)

reports table:
  id (UUID), reporter_id (FK), reported_user_id (FK), reason, 
  room_id (FK), status ('pending'/'reviewed'/'actioned'), 
  reviewed_by (FK), action_taken, created_at
```

---

## Security & Anti-Abuse Rules
- All coin/gift/level operations → Edge Functions or PostgreSQL RPC functions (atomic + validation)
- Row Level Security (RLS) policies: only authenticated users, owner/admin can write to room participants
- Rate limit requests to speak (max 3 requests per room, PostgreSQL counter with unique constraints)
- Ban system: global bans in users table + room-specific bans
- **Zego token expiry**: 24h max, regenerate on expiry
- **API key protection**: Never expose Supabase/Zego keys in client (use Edge Functions, RLS policies)
- **Input validation**: Sanitize all user inputs (room titles, messages, names) - use PostgreSQL constraints
- **GDPR compliance**: User data export/deletion via Edge Functions
- **PCI compliance**: No credit card storage (RevenueCat handles it)
- **Database security**: Enable RLS on all tables, use service_role key only in Edge Functions

## Supabase Edge Functions (Backend Logic)

### 1. `generate-zego-token`
- Input: userId, roomId (from JWT token + request body)
- Validate user is authenticated + not banned (query users table)
- Generate Zego token with 24h expiry using Zego server SDK
- Return token + Zego appId

### 2. `process-gift-transaction`
- Validate sender has enough coins (SELECT coins FROM users WHERE id = sender_id)
- PostgreSQL transaction: 
  - Deduct from sender: `UPDATE users SET coins = coins - amount WHERE id = sender_id`
  - Add to receiver (70%): `UPDATE users SET coins = coins + (amount * 0.7) WHERE id = receiver_id`
  - Platform fee (30%) tracked in transactions table
- Insert transaction records
- Trigger gift animation via Supabase Realtime broadcast to room
- Update receiver's total_gifts_value + check level up (call update-user-level)
- Return success + new balances

### 3. `update-user-level`
- Calculate level from monthly_gifts_value
- If level increased → send notification + reward bonus coins
- Update user record
- Trigger level-up celebration via Realtime

### 4. `validate-room-permissions` (or use PostgreSQL RPC function)
- Check if user has permission for action (mute, kick, make admin)
- Query room ownership, admin status from database
- Return bool

### 5. `revenuecat-webhook`
- Listen to RevenueCat webhooks (purchase, renewal, cancellation)
- Verify webhook signature
- Add coins to user account (UPDATE users SET coins = coins + amount)
- Activate/update VIP subscription in vip_subscriptions table
- Insert transaction record

### 6. `reset-monthly-levels` (scheduled via pg_cron or Supabase scheduled functions)
- Reset all users' monthly_gifts_value to 0: `UPDATE users SET monthly_gifts_value = 0`
- Recalculate levels via trigger or batch update
- Send summary email to users (integrate with SendGrid/Resend)

### 7. `moderate-content`
- Auto-review reports
- Flag users with >10 reports: `SELECT * FROM users WHERE report_count > 10`
- Notify admins via push notification or email

### 8. `generate-leaderboard` (scheduled, daily)
- Aggregate gift data using SQL queries with window functions
- UPSERT into leaderboard table
- Clear previous period data
- Refresh materialized views

### 9. `cleanup-inactive-rooms` (scheduled, hourly)
- Find rooms with 0 participants for >10 mins:
  `SELECT * FROM rooms WHERE status = 'live' AND id NOT IN (SELECT DISTINCT room_id FROM live_room_participants)`
- Update status to 'ended'
- Archive data (rooms table keeps history)

### 10. `handle-user-deletion` (GDPR)
- Delete user data from PostgreSQL tables (CASCADE on foreign keys)
- Anonymize transaction history: `UPDATE transactions SET user_id = null WHERE user_id = deleted_user_id`
- Delete from Supabase Storage
- Revoke Zego tokens
- Remove from all room relationships

## Performance Budget & Optimization

### App Performance Targets
- **Room UI**: 60fps even with 20 speakers (use RepaintBoundary for avatars)
- **Gift animations**: <2s for expensive gifts, <1s for cheap gifts
- **Room join time**: <3s from tap to audio stream
- **App size**: <50MB (use code splitting, optimize images)
- **Memory**: <150MB RAM usage in active room
- **Battery**: <10% drain per hour (optimize Zego audio only mode)

### Network Requirements
- **Minimum**: 3G (128kbps) for audio only
- **Recommended**: 4G (1Mbps+) for smooth experience
- **Offline mode**: Show cached room list, disable join
- **Poor connection**: Auto-downgrade audio quality, show warning

### Database Optimization
- **PostgreSQL queries**: Optimize with proper indexes on frequently queried columns (status, created_at, user_id, room_id)
- **Supabase Realtime**: Use for live room participants and speaking indicators
- **Connection pooling**: Supabase handles this automatically (Supavisor)
- **Storage**: Compress profile images to 200x200 (use cached_network_image)
- **Edge Functions**: Fast cold starts with Deno runtime (~50-200ms)
- **Materialized views**: For expensive aggregations (leaderboards, analytics)
- **Partial indexes**: For status-based queries (e.g., `WHERE status = 'live'`)
- **JSONB columns**: For flexible metadata storage with GIN indexes

### Animation Optimization
- **Gift effects**: Use Lottie for complex animations (max 500KB per animation)
- **Level frames**: SVG or vector assets (not PNG)
- **Preload**: Cache frequently used assets

## Testing Strategy

### Unit Tests (>80% coverage)
- All BLoC/Cubit classes
- All UseCases
- All Repository implementations
- Utils & helpers

### Integration Tests
- Row Level Security policies (test with different user roles using Supabase client)
- Edge Functions (test locally with Supabase CLI)
- Payment flows (RevenueCat sandbox)
- Zego audio (mock SDK in tests)
- PostgreSQL triggers and functions

### Widget Tests
- Key user flows: login, join room, send gift
- Custom widgets: speaker view, gift tray

### E2E Tests (Critical Paths)
- Register → Join room → Send gift → Leave
- Create room → Invite speaker → Mute user
- Purchase coins → Send expensive gift → Check balance

### Manual Testing
- Test on low-end devices (2GB RAM Android)
- Test on poor networks (3G simulation)
- Test with 20+ concurrent users in room
- Test Zego reconnection (toggle airplane mode)
- Test background audio (lock screen, switch apps)

## Development Order Recommendation (for AI agent)

### Phase 1: Foundation (Week 1-2)
1. Project setup + folder structure + DI (get_it)
2. Supabase setup: Create PostgreSQL schema, enable RLS
3. Auth (Phone OTP via Twilio + Google/Apple OAuth) + Age verification
4. User Profile (basic CRUD)
5. Row Level Security policies (initial setup for users table)
6. Error handling framework (dartz)

### Phase 2: Core Room Feature (Week 3-4)
7. PostgreSQL schema for rooms, room_participants, speaker_requests tables
8. Home + Room discovery (PostgreSQL queries + filters)
9. Create Room (UI + PostgreSQL insert)
10. Join Room + Zego integration (audio only, basic token generation Edge Function)
11. Speaker/Audience roles (basic)
12. Leave room cleanup + Realtime subscriptions

### Phase 3: Moderation & Social (Week 5-6)
13. Speaker requests + approval system
14. Mute/Kick/Ban (owner/admin actions with PostgreSQL transactions)
15. Supabase Realtime subscriptions for live room state
16. Network quality indicator
17. Text chat in rooms (room_messages table + Realtime)
18. Follow/Unfollow system (follows table with triggers)
19. Report & Block users (reports table + blocked_users array)

### Phase 4: Monetization (Week 7-8)
20. Coins system (PostgreSQL transactions with atomic operations)
21. RevenueCat integration + coin packages
22. VIP subscription setup (vip_subscriptions table)
23. Edge Function webhook for RevenueCat
24. Restore purchases
25. Wallet UI + transaction history (transactions table)

### Phase 5: Gifting & Gamification (Week 9-10)
26. Gift catalog table (gifts table with metadata)
27. Send gift flow (UI + Edge Function for process-gift-transaction)
28. Gift animations (Lottie) + Realtime broadcast
29. Levels system (calculation + UI with PostgreSQL triggers)
30. Level frames + badges
31. Leaderboard (scheduled Edge Function + materialized views + UI)

### Phase 6: Polish & Engagement (Week 11-12)
32. Notifications (FCM/OneSignal + notifications table)
33. Deep linking (room invites with Supabase redirect handling)
34. Background audio (iOS + Android)
35. Analytics events (analytics_events table + PostHog integration)
36. Onboarding flow (tutorial)
37. Settings (privacy, account, notifications)

### Phase 7: Optimization & Launch Prep (Week 13-14)
38. Performance optimization (60fps target)
39. Testing (unit, integration, E2E)
40. Edge Functions optimization + scheduled tasks (pg_cron)
41. Security audit (RLS policies review, Edge Functions security)
42. PostgreSQL query optimization (EXPLAIN ANALYZE)
43. App Store / Play Store assets
44. Beta testing (TestFlight, Supabase edge function staging)

## Post-Launch Features (Backlog)
- Private messaging (1-on-1 voice/text)
- Room recordings (for creators)
- Scheduled rooms (calendar integration)
- Co-hosting (multiple owners)
- Room themes (custom backgrounds)
- Mini-games in rooms (trivia, polls)
- Creator dashboard (analytics, earnings)
- Withdrawals (PayPal, bank transfer)
- Multi-language support (i18n)
- Accessibility (screen reader, captions)

Good luck building this exciting social audio experience!  
Start with auth → then room skeleton → then add the magic. 🚀