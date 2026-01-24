# ZEGO Token Authentication Error 50119 - Fix Guide

## Problem
Token authentication is failing with error code **50119** (`token auth err`), causing the Zego room connection to fail with error **1102016** (`liveroom error`).

## Root Cause
The error indicates that the ZEGO server is rejecting the token, which typically means:
1. **Wrong Server Secret** (most common)
2. Wrong App ID
3. Incorrect token format
4. Token expired or invalid timestamp

## Solution Steps

### Step 1: Verify Your ZEGO Credentials

1. **Login to ZEGO Console**: https://console.zego.im/
2. **Navigate to** your project: "Social Voice"
3. **Find these credentials**:
   - **AppID**: Should be a number (e.g., `424135686`)
   - **ServerSecret**: Should be a 64-character hexadecimal string

### Step 2: Update the Edge Function with Correct Credentials

Open your ZEGO Console and get the **EXACT** Server Secret:

```
ZEGO Console > Your Project > App Config > ServerSecret
```

**CRITICAL**: The ServerSecret is **NOT** the "SignKey". Make sure you're copying the **ServerSecret** field.

#### Option A: Update the hardcoded values (Quick test)

Edit: `supabase/functions/generate-zego-token/index.ts`

```typescript
const appID = 424135686; // Replace with YOUR AppID
const serverSecretHex = 'YOUR_64_CHAR_HEX_STRING'; // Replace with YOUR ServerSecret
```

#### Option B: Use environment variables (Recommended for production)

1. Create `.env` file in your Supabase project:
```bash
ZEGO_APP_ID=424135686
ZEGO_SERVER_SECRET=your_64_char_hex_string_here
```

2. Deploy with environment variables:
```bash
supabase functions deploy generate-zego-token \
  --secret ZEGO_APP_ID=424135686 \
  --secret ZEGO_SERVER_SECRET=your_64_char_hex_string_here
```

### Step 3: Redeploy the Edge Function

After updating the credentials:

```bash
cd c:\Users\hp\Documents\project_t\social_voice
supabase functions deploy generate-zego-token
```

### Step 4: Test the Token Generation

You can test the token directly:

```bash
curl -X POST https://your-project.supabase.co/functions/v1/generate-zego-token \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -d '{"userId":"test-user-123","roomId":"test-room-456"}'
```

### Step 5: Verify Token Format

The generated token should:
- Start with `04` (version flag)
- Be base64 encoded after the version flag
- Be around 300-400 characters long

Example valid token:
```
04AAAAAGl12rEADMPf9z80dy5z9B4V3AEL/HfgpK6rw0+LjEmMkZVfodwzJIvPY9...
```

## What Changed in the Fix

1. **Added environment variable support** for App ID and Server Secret
2. **Improved payload handling** - uses room-level privileges only when roomId is provided
3. **Added validation** for ServerSecret format (must be 64 hex characters)
4. **Enhanced logging** to debug token generation
5. **Fixed 64-bit integer encoding** for expire time
6. **Clarified AES-GCM tag handling** in encryption

## Common Mistakes to Avoid

❌ **Using SignKey instead of ServerSecret**
❌ **Using App Secret instead of ServerSecret**
❌ **Copying ServerSecret with spaces or newlines**
❌ **Using wrong App ID (from different project)**

✅ **Use the exact 64-character hex ServerSecret from ZEGO Console**
✅ **Ensure App ID matches your ZEGO project**
✅ **Test with a fresh token after any changes**

## Testing Checklist

- [ ] Verified App ID from ZEGO Console
- [ ] Copied exact ServerSecret (64 hex chars)
- [ ] Redeployed Edge Function
- [ ] Token generation returns 200 OK
- [ ] Token starts with "04"
- [ ] Token is ~300-400 chars long
- [ ] Room connection succeeds (no error 50119)

## Debug Logs to Check

When testing, check these logs in your app:

```
✅ TOKEN RECEIVED SUCCESSFULLY!
   ├─ App ID: 424135686
   ├─ Token Length: 394 chars
   └─ Expires In: 86400 seconds
```

And in Zego logs, you should see:
```
{"action":"zm.al","content":"roomStateChanged [\"room-id\",\"LOGIN\",0,null]"}
```

**NOT**:
```
{"action":"zm.rm.lgr","content":"server error=50119"}
```

## Need More Help?

If the issue persists after verifying credentials:

1. Check ZEGO service status: https://status.zego.im/
2. Verify your ZEGO account is active and not expired
3. Check if IP whitelisting is required in your ZEGO project settings
4. Contact ZEGO support with your App ID (don't share ServerSecret!)

## Reference

- ZEGO Token Documentation: https://docs.zegocloud.com/article/11648
- ZEGO Error Codes: https://docs.zegocloud.com/article/4378
- Token04 Algorithm: https://github.com/zegoim/zego_server_assistant/tree/main/token/nodejs/token04
