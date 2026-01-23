# Edge Function Deployment Guide

## ⚠️ CRITICAL: Your deployed Edge Function is using the WRONG ServerSecret!

**Evidence:**
- Local file generates: **319-character tokens** ✅ (correct)
- Deployed function generates: **301-character tokens** ❌ (wrong)
- App receives: **380-character tokens** ❌ (even older version!)

This proves the deployed Edge Function has NOT been updated with the correct ServerSecret.

---

## 🚀 Deployment Steps

### Method 1: Supabase Dashboard (Use this)

1. **Open Supabase Dashboard**:
   https://supabase.com/dashboard/project/dshtknsycapihbehvxnv/functions

2. **Click** on `generate-zego-token`

3. **Click** "Edit Function" or "Deploy" button

4. **Delete all existing code** in the editor

5. **Copy the ENTIRE code** from:
   `C:\Users\hp\Documents\project_t\social_voice\supabase\functions\generate-zego-token\index.ts`

6. **Paste** into the Supabase editor

7. **Verify line 36** shows:
   ```typescript
   const serverSecret = 'cf9731c4c78acf97c41283b137164eec';  // ← 32 chars, CORRECT
   ```

8. **Click** "Deploy" button at the bottom

9. **Wait** for deployment to complete (usually 10-30 seconds)

10. **Verify deployment**:
    - Check "Deployments" tab shows recent timestamp
    - Token length should now be 319 characters

---

## ✅ Verification After Deployment

Run this in PowerShell to verify:

```powershell
$response = Invoke-RestMethod -Uri "https://dshtknsycapihbehvxnv.supabase.co/functions/v1/generate-zego-token" -Method Post -Body '{"userId":"verify123","roomId":"verify456"}' -ContentType "application/json"

Write-Host "`nToken Length: $($response.token.Length) characters"

if ($response.token.Length -eq 319) {
    Write-Host "✅ SUCCESS: Deployment verified! Token length correct." -ForegroundColor Green
} else {
    Write-Host "❌ FAILED: Still wrong. Expected 319, got $($response.token.Length)" -ForegroundColor Red
}
```

---

## 🔍 What's Wrong?

**The Problem:**
- Your app is getting 380-character tokens
- Our independent test got 301-character tokens  
- Correct token should be 319 characters

**The Cause:**
The deployed Edge Function is using the WRONG ServerSecret:
- ❌ **Wrong (deployed)**: `5323ca723c6abb1eebb55f38ee067aa21a1cd635977694e35650fb0814cdf9` (62 chars - AppSign)
- ✅ **Correct (local file)**: `cf9731c4c78acf97c41283b137164eec` (32 chars - ServerSecret)

**The Fix:**
Redeploy the Edge Function with the correct ServerSecret value.

---

## 📝 After Successful Deployment

1. **Hard refresh your Flutter app**: Press `Ctrl + Shift + R` in Chrome

2. **Restart the Flutter app**:
   ```powershell
   # Stop current app
   flutter run -d chrome
   ```

3. **Try joining a room again**

4. **Expected result**: Error 50119 should be GONE!

---

## 🆘 If Deployment Fails

**Check:**
1. Are you logged into the correct Supabase project?
2. Do you have edit permissions for Edge Functions?
3. Is the function syntax correct (no missing brackets, quotes, etc.)?

**Alternative:** Take a screenshot of the deployed function code in Supabase Dashboard and share it.
