# Firebase to Supabase Migration Guide

## ✅ Completed Migration Steps

### 1. Dependencies Updated
- ✅ Removed all Firebase packages:
  - `firebase_core`
  - `firebase_auth`
  - `cloud_firestore`
  - `firebase_storage`
  - `firebase_messaging`
  - `firebase_analytics`
  - `firebase_database`
  - `firebase_dynamic_links`
  
- ✅ Added Supabase packages:
  - `supabase_flutter: ^2.5.10`
  - `app_links: ^6.3.2` (for deep linking)

### 2. Configuration Files
- ✅ Created `supabase_config.dart` with project credentials
  - Project URL: `https://dshtknsycapihbehvxnv.supabase.co`
  - Anon Key: `eyJhbGci...` (configured)
  
- ⚠️ Old `firebase_options.dart` can be deleted

### 3. Core Changes

#### main.dart
- ✅ Replaced Firebase initialization with Supabase initialization
- ✅ Now using `Supabase.initialize()` with config

#### Dependency Injection (injection_container.dart)
- ✅ Removed Firebase service instances
- ✅ Added Supabase client singleton
- ✅ Updated auth datasource injection

#### Auth Data Source (auth_remote_datasource.dart)
- ✅ Complete rewrite for Supabase Auth
- ✅ Phone OTP now using Supabase (requires Twilio setup)
- ✅ Google Sign-In integration with Supabase
- ✅ Email/Password authentication
- ✅ PostgreSQL queries replace Firestore queries

#### User Model (user_model.dart)
- ✅ Updated JSON serialization for PostgreSQL compatibility
- ✅ Changed `uid` to map to `id` column
- ✅ Added snake_case field mapping

## 🔧 Next Steps Required

### 1. Database Setup in Supabase Dashboard

Execute the SQL schema provided in `supabase_schema.sql`:

```bash
# Using Supabase CLI (recommended)
supabase db reset

# Or copy the SQL from supabase_schema.sql and execute in:
# Supabase Dashboard > SQL Editor
```

**Key tables to verify:**
- `users` - User profiles
- `rooms` - Voice chat rooms
- `live_room_participants` - Real-time state (Realtime enabled)
- `room_gifts` - Gift animations (Realtime enabled)
- `transactions` - Coin transactions
- `follows` - Social graph
- `notifications` - Push notifications
- And 15+ more tables...

### 2. Enable Realtime on Tables

In Supabase Dashboard > Database > Replication:
```sql
-- Enable Realtime for live features
ALTER PUBLICATION supabase_realtime ADD TABLE live_room_participants;
ALTER PUBLICATION supabase_realtime ADD TABLE room_gifts;
```

### 3. Configure Authentication Providers

#### Supabase Dashboard > Authentication > Providers:

**Phone (Twilio):**
1. Go to Authentication > Providers > Phone
2. Enable Phone provider
3. Add Twilio credentials:
   - Twilio Account SID
   - Twilio Auth Token
   - Twilio Phone Number

**Google OAuth:**
1. Go to Authentication > Providers > Google
2. Enable Google provider
3. Add Google OAuth credentials:
   - Client ID (Web)
   - Client Secret
   - Add redirect URL: `https://dshtknsycapihbehvxnv.supabase.co/auth/v1/callback`

4. Update `app_constants.dart` with Google Client ID:
```dart
static const String googleClientId = 'YOUR_ACTUAL_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
```

### 4. Set Up Storage Buckets

Supabase Dashboard > Storage > Create new buckets:

```
avatars/
  - Public bucket
  - Max file size: 5MB
  - Allowed types: image/png, image/jpeg, image/webp

room-backgrounds/
  - Public bucket
  - Max file size: 10MB
  - Allowed types: image/*

gift-animations/
  - Public bucket
  - Max file size: 2MB
  - Allowed types: application/json (Lottie files)
```

### 5. Install Dependencies

```bash
cd c:\Users\hp\Documents\project_t\social_voice
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. Update Environment-Specific Configs

Add to `app_constants.dart`:
```dart
// Replace these placeholders:
static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
static const int zegoAppId = YOUR_ZEGO_APP_ID;
static const String zegoAppSign = 'YOUR_ZEGO_APP_SIGN';
```

### 7. Test Authentication Flows

```bash
flutter run
```

Test in this order:
1. ✅ Phone OTP Login (requires Twilio setup)
2. ✅ Google Sign-In
3. ✅ Email/Password Registration
4. ✅ Age Verification
5. ✅ Profile Creation

### 8. Create Supabase Edge Functions (Backend Logic)

Create these Edge Functions for backend operations:

**generate-zego-token:**
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  // Generate Zego token for voice room access
  // Validate user authentication
  // Return token with 24h expiry
})
```

**process-gift-transaction:**
```typescript
// Handle gift sending with atomic PostgreSQL transactions
// Deduct coins from sender
// Add coins to receiver (70%)
// Record platform fee (30%)
// Trigger Realtime broadcast for animation
```

**revenuecat-webhook:**
```typescript
// Listen to RevenueCat purchase events
// Add coins to user account
// Activate VIP subscriptions
```

### 9. Verify Row Level Security (RLS)

All tables have RLS policies defined. Test with different users to ensure:
- ✅ Users can only update their own profiles
- ✅ Users can only see their own transactions
- ✅ Room owners can manage their rooms
- ✅ Public data is accessible to all

### 10. Performance Optimization

- ✅ All tables have proper indexes
- ✅ Triggers auto-update follower counts
- ✅ Materialized views for leaderboards (optional)
- ✅ Partitioning for analytics events (recommended for scale)

## 📋 Migration Checklist

- [x] Update pubspec.yaml dependencies
- [x] Create Supabase configuration
- [x] Migrate main.dart initialization
- [x] Update dependency injection
- [x] Rewrite auth datasource for Supabase
- [x] Update user model for PostgreSQL
- [x] Create complete database schema
- [ ] Execute SQL schema in Supabase
- [ ] Enable Realtime on required tables
- [ ] Configure Twilio for phone auth
- [ ] Configure Google OAuth
- [ ] Create storage buckets
- [ ] Run `flutter pub get`
- [ ] Test authentication flows
- [ ] Create Edge Functions
- [ ] Deploy and test

## 🚨 Breaking Changes

### API Method Signatures Changed:

**Before (Firebase):**
```dart
Future<UserModel> verifyPhoneCode({
  required String verificationId,
  required String smsCode,
})
```

**After (Supabase):**
```dart
Future<UserModel> verifyPhoneCode({
  required String phoneNumber,
  required String token,
})
```

**Impact:** Update any BLoC/Cubit that calls `verifyPhoneCode`

### Database Query Changes:

**Before:**
```dart
await firestore.collection('users').doc(uid).get()
```

**After:**
```dart
await supabase.from('users').select().eq('id', uid).single()
```

## 🔗 Important Links

- Supabase Dashboard: https://supabase.com/dashboard/project/dshtknsycapihbehvxnv
- Supabase Docs: https://supabase.com/docs
- Supabase Flutter: https://supabase.com/docs/reference/dart/introduction
- Database Schema: `supabase_schema.sql`

## 📞 Support

If you encounter issues:
1. Check Supabase Dashboard > Logs
2. Verify RLS policies in Database > Policies
3. Check Edge Function logs
4. Review authentication provider settings

## 🎉 Benefits of Migration

✅ **PostgreSQL** - Powerful relational database with JSONB support  
✅ **Real-time subscriptions** - Built-in WebSocket support  
✅ **Row Level Security** - Database-level security  
✅ **Edge Functions** - Deno-based serverless functions  
✅ **Better cost structure** - More generous free tier  
✅ **SQL joins** - Efficient relational queries  
✅ **Open source** - Full control and transparency
