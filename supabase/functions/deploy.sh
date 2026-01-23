#!/bin/bash
# Quick Deploy Script for Zego Token Edge Function
# Run this from the project root directory

echo "🚀 Deploying Zego Token Edge Function..."

# Set secrets
echo "📝 Setting Supabase secrets..."
supabase secrets set ZEGO_APP_ID=424135686
supabase secrets set ZEGO_SERVER_SECRET=5323ca723c6abb1ee6b55f38ee067aa21a1cd6351977d694e35650fb0814cdf9

# Deploy function
echo "📦 Deploying function..."
supabase functions deploy generate-zego-token

echo "✅ Deployment complete!"
echo ""
echo "Test with:"
echo "curl -i --location --request POST 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/generate-zego-token' \\"
echo "  --header 'Authorization: Bearer YOUR_ANON_KEY' \\"
echo "  --header 'Content-Type: application/json' \\"
echo "  --data '{\"userId\":\"test-user\",\"roomId\":\"test-room\"}'"
