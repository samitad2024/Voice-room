# 🔍 Quick Verification Checklist

## Before Testing

- [ ] Edge function deployed: `supabase functions deploy generate-zego-token`
- [ ] Flutter dependencies updated: `flutter pub get`
- [ ] App cleaned and rebuilt: `flutter clean && flutter run`

## Testing Checklist

### 1. Token Generation ✅
- [ ] Edge function responds with 200 status
- [ ] Token is ~200-250 characters long
- [ ] Token has 3 parts (header.payload.signature)
- [ ] Response includes: token, appID, userId, roomId, expiresIn

### 2. Zego Initialization ✅
- [ ] No "please use valid scenario" error
- [ ] Engine initializes successfully
- [ ] Audio settings applied (AEC, AGC, ANS)

### 3. Room Creation ✅
- [ ] Room creates in Supabase database
- [ ] Token is requested from edge function
- [ ] No "token auth err" (50119) error
- [ ] Room state changes to "Connected"
- [ ] Host can publish audio stream

### 4. Room Joining ✅
- [ ] Token is requested with correct roomId
- [ ] User joins room successfully
- [ ] Room state changes to "Connected"
- [ ] Audience can hear host

## Debug Logs to Look For

### ✅ Success Indicators:
```
✅ Zego Engine initialized successfully
✅ Token received (XXX chars)
✅ Successfully joined room: ROOM_ID
🎤 Starting to publish stream: STREAM_ID
Room state changed: ROOM_ID - ZegoRoomState.Connected
```

### ❌ Error Indicators (Should NOT see these anymore):
```
❌ token auth err
❌ please use valid scenario
❌ Failed to join room
❌ Failed to generate token
```

## Console Commands for Testing

### Test Edge Function
```powershell
# Test token generation (replace with your values)
curl -X POST "https://YOUR_PROJECT_REF.supabase.co/functions/v1/generate-zego-token" `
  -H "Authorization: Bearer YOUR_ANON_KEY" `
  -H "Content-Type: application/json" `
  -d '{\"userId\":\"test-user\",\"roomId\":\"test-room\"}'
```

### Check Edge Function Logs
```powershell
supabase functions logs generate-zego-token --tail
```

### Run Flutter with Verbose Logging
```powershell
flutter run -v
```

## What Fixed the Issue

1. **Scenario**: Changed from `Communication` to `Standard`
2. **Token Format**: Added `stream_id_list: null` and `appSign: null`
3. **Token Expiry**: Extended from 1 hour to 24 hours
4. **Error Handling**: Added comprehensive logging and user feedback

## If Issues Persist

Check these in order:

1. **Verify Credentials**
   - AppID: `424135686` (in both edge function and Flutter config)
   - ServerSecret: Full 64-character string from Zego Console

2. **Check Edge Function Deployment**
   ```powershell
   supabase functions list
   # Should show: generate-zego-token
   ```

3. **Verify Token Format**
   - Token should be JWT format: `header.payload.signature`
   - Each part should be base64url encoded
   - No `04` prefix

4. **Check Zego Account**
   - Login to Zego Console
   - Verify project is active
   - Check usage limits

## Success Criteria

✅ **FIXED** when you can:
1. Create a room without crashes
2. Join a room without "token auth err"
3. See "Connected" status in logs
4. Hear audio from speakers

---

**Last Updated:** 2026-01-21
**Status:** Ready for Testing
