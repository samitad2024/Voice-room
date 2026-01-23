# Quick Deploy Script for Zego Token Edge Function (PowerShell)
# Run this from the project root directory

Write-Host "🚀 Deploying Zego Token Edge Function..." -ForegroundColor Cyan

# Set secrets
Write-Host "📝 Setting Supabase secrets..." -ForegroundColor Yellow
supabase secrets set ZEGO_APP_ID=424135686
supabase secrets set ZEGO_SERVER_SECRET=5323ca723c6abb1ee6b55f38ee067aa21a1cd6351977d694e35650fb0814cdf9

# Deploy function
Write-Host "📦 Deploying function..." -ForegroundColor Yellow
supabase functions deploy generate-zego-token

Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Test with:" -ForegroundColor Cyan
Write-Host "curl -i --location --request POST 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/generate-zego-token' \"
Write-Host "  --header 'Authorization: Bearer YOUR_ANON_KEY' \"
Write-Host "  --header 'Content-Type: application/json' \"
Write-Host "  --data '{""userId"":""test-user"",""roomId"":""test-room""}'"
