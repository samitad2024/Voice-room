# Zego Token Edge Function - Deployment Guide

## Your Zego Credentials
- **App ID**: 424135686
- **Server Secret**: 5323ca723c6abb1ee6b55f38ee067aa21a1cd6351977d694e35650fb0814cdf9

## Deployment Steps

### 1. Install Supabase CLI (if not already installed)
```bash
# Windows (PowerShell)
scoop install supabase

# Or using npm
npm install -g supabase
```

### 2. Login to Supabase
```bash
supabase login
```

### 3. Link Your Project
```bash
# Get your project reference from Supabase Dashboard > Settings > API
supabase link --project-ref YOUR_PROJECT_REF
```

### 4. Set Secrets (IMPORTANT - Never commit these!)
```bash
supabase secrets set ZEGO_APP_ID=424135686
supabase secrets set ZEGO_SERVER_SECRET=5323ca723c6abb1ee6b55f38ee067aa21a1cd6351977d694e35650fb0814cdf9
```

### 5. Deploy the Edge Function
```bash
# From the project root directory
supabase functions deploy generate-zego-token
```

### 6. Test the Function
```bash
# Using curl
curl -i --location --request POST 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/generate-zego-token' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"userId":"test-user-123","roomId":"test-room-456"}'
```

Expected response:
```json
{
  "token": "04XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}
```

## Alternative: Deploy via Supabase Dashboard

1. Go to your Supabase Dashboard
2. Navigate to **Edge Functions** in the sidebar
3. Click **Create a new function**
4. Name it: `generate-zego-token`
5. Copy the code from `supabase/functions/generate-zego-token/index.ts`
6. Click **Deploy function**
7. Go to **Settings** > **Edge Functions** > **Secrets**
8. Add the secrets:
   - `ZEGO_APP_ID` = `424135686`
   - `ZEGO_SERVER_SECRET` = `5323ca723c6abb1ee6b55f38ee067aa21a1cd6351977d694e35650fb0814cdf9`

## Security Notes

- ✅ AppID is safe to expose in client code (it's in zego_config.dart)
- ❌ NEVER expose ServerSecret in client code - always use Edge Functions
- ✅ Tokens expire after 1 hour (configured in the function)
- ✅ CORS is enabled for your Flutter app
- ✅ Supabase Auth is required (anon key needed)

## Troubleshooting

### Function returns "Missing Zego secrets"
- Make sure you ran `supabase secrets set` commands
- Verify secrets in Dashboard > Settings > Edge Functions > Secrets

### Function returns "Missing userId or roomId"
- Check your request body includes both fields
- Ensure Content-Type header is `application/json`

### Token generation fails
- Verify your AppID and ServerSecret are correct
- Check Supabase function logs: Dashboard > Edge Functions > Logs

### Flutter app can't call function
- Ensure you're using `Supabase.instance.client.functions.invoke()`
- Check your Supabase anon key is configured in Flutter
- Verify CORS headers are correct

## Function URL
After deployment, your function will be available at:
```
https://YOUR_PROJECT_REF.supabase.co/functions/v1/generate-zego-token
```

Replace `YOUR_PROJECT_REF` with your actual Supabase project reference.
