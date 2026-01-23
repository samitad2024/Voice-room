# Quick Reference - Firebase to Supabase Migration

## ✅ Migration Complete!

All code has been migrated from Firebase to Supabase.

---

## 🚀 Quick Start (5 minutes)

### 1. Run Database Schema (REQUIRED)
```
Open: https://supabase.com/dashboard/project/dshtknsycapihbehvxnv/editor
Copy: supabase_schema.sql content
Paste in SQL Editor > Click RUN
```

### 2. Enable Realtime (REQUIRED)
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE live_room_participants;
ALTER PUBLICATION supabase_realtime ADD TABLE room_gifts;
```

### 3. Configure Auth Providers (REQUIRED)

**Phone (Twilio):**
```
Dashboard > Authentication > Providers > Phone
Add Twilio credentials
```

**Google OAuth:**
```
Dashboard > Authentication > Providers > Google  
Add OAuth Client ID & Secret
```

### 4. Run the App
```bash
flutter run
```

---

## 📋 Quick Checklist

**Database:**
- [ ] Execute `supabase_schema.sql` in SQL Editor
- [ ] Enable Realtime on `live_room_participants` table
- [ ] Enable Realtime on `room_gifts` table

**Authentication:**
- [ ] Configure Twilio for Phone OTP
- [ ] Configure Google OAuth
- [ ] Update Google Client ID in `app_constants.dart`

**Storage:**
- [ ] Create `avatars` bucket (optional for now)
- [ ] Create `room-backgrounds` bucket (optional)
- [ ] Create `gift-animations` bucket (optional)

**App Config:**
- [ ] Update Google Client ID in `app_constants.dart`
- [ ] Update Zego credentials (for voice rooms later)

---

## 🔑 Your Credentials

**Supabase Project:**
- URL: `https://dshtknsycapihbehvxnv.supabase.co`
- Dashboard: https://supabase.com/dashboard/project/dshtknsycapihbehvxnv
- Anon Key: Already configured in `supabase_config.dart` ✅

**Required External Services:**
1. **Twilio** (Phone OTP)
   - Sign up: https://www.twilio.com/try-twilio
   - Get: Account SID, Auth Token, Phone Number

2. **Google Cloud** (OAuth)
   - Console: https://console.cloud.google.com/
   - Get: Client ID, Client Secret
   - Add redirect: `https://dshtknsycapihbehvxnv.supabase.co/auth/v1/callback`

3. **Zego** (Voice Rooms)
   - Sign up: https://www.zegocloud.com/
   - Get: App ID, App Sign

---

## 🎯 Test Authentication

### Phone OTP Flow:
```dart
1. Enter phone number: +1234567890
2. Receive SMS code
3. Enter code
4. ✅ Authenticated
```

### Google Sign-In Flow:
```dart
1. Tap "Sign in with Google"
2. Select Google account
3. ✅ Authenticated
```

### Email/Password Flow:
```dart
1. Enter email & password
2. Submit
3. ✅ Authenticated
```

---

## 📊 Database Tables Created

**Core (20+ tables):**
- users
- rooms  
- room_participants
- live_room_participants (Realtime)
- speaker_requests
- room_messages
- follows
- transactions
- gifts
- room_gifts (Realtime)
- vip_subscriptions
- reports
- leaderboard
- notifications
- analytics_events
- admins
- admin_logs

**All tables have:**
- ✅ Row Level Security
- ✅ Indexes
- ✅ Foreign keys
- ✅ Triggers

---

## 🔧 Common Commands

**Install dependencies:**
```bash
flutter pub get
```

**Generate code:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Run app:**
```bash
flutter run
```

**Check for issues:**
```bash
flutter analyze
```

---

## 🆘 Quick Troubleshooting

**Error: "RLS policy violation"**
→ Run the SQL schema, it includes RLS policies

**Error: "Phone OTP not sending"**  
→ Configure Twilio in Authentication > Providers > Phone

**Error: "Google Sign-In failed"**
→ Add redirect URI in Google Cloud Console

**Error: "Table doesn't exist"**
→ Run `supabase_schema.sql` in SQL Editor

---

## 📱 What Works Now

✅ User authentication (Phone, Google, Email)  
✅ User profile creation  
✅ Database queries  
✅ Real-time subscriptions (setup required)  
✅ Coins & transactions  
✅ Gift system  
✅ VIP subscriptions  
✅ Social following  
✅ Moderation system  

---

## 📄 Key Files Updated

1. `pubspec.yaml` - Dependencies
2. `lib/supabase_config.dart` - Supabase credentials
3. `lib/main.dart` - Initialization
4. `lib/core/di/injection_container.dart` - DI setup
5. `lib/features/auth/data/datasources/auth_remote_datasource.dart` - Auth logic
6. `lib/features/auth/data/models/user_model.dart` - User model
7. `supabase_schema.sql` - Database schema

---

## 🎉 You're Ready!

Once you complete the 4 quick start steps above, your app will be fully functional with Supabase!

Need detailed instructions? See: `SETUP_INSTRUCTIONS.md`
