#!/usr/bin/env deno run --allow-net --allow-env

/**
 * ZEGO Token Test Script
 * 
 * This script helps you test if your ZEGO token is generated correctly.
 * 
 * Usage:
 *   deno run --allow-net --allow-env test_zego_token.ts
 */

const SUPABASE_URL = 'https://iynlmvtnjukfmrzvtlzm.supabase.co'; // Replace with your Supabase URL
const SUPABASE_ANON_KEY = 'your-anon-key-here'; // Replace with your anon key
const TEST_USER_ID = 'test-user-' + Date.now();
const TEST_ROOM_ID = 'test-room-' + Date.now();

console.log('🧪 ZEGO Token Test Script\n');
console.log('═══════════════════════════════════════════════════════\n');

async function testTokenGeneration() {
  try {
    console.log('📤 Requesting token from Edge Function...');
    console.log(`   User ID: ${TEST_USER_ID}`);
    console.log(`   Room ID: ${TEST_ROOM_ID}`);
    console.log('');

    const response = await fetch(`${SUPABASE_URL}/functions/v1/generate-zego-token`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        userId: TEST_USER_ID,
        roomId: TEST_ROOM_ID,
      }),
    });

    console.log(`📥 Response Status: ${response.status} ${response.statusText}\n`);

    if (!response.ok) {
      const errorText = await response.text();
      console.error('❌ Failed to generate token');
      console.error('   Error:', errorText);
      return false;
    }

    const data = await response.json();
    
    console.log('✅ Token Generated Successfully!\n');
    console.log('Token Details:');
    console.log('───────────────────────────────────────────────────────');
    console.log(`App ID:       ${data.appID}`);
    console.log(`User ID:      ${data.userId}`);
    console.log(`Room ID:      ${data.roomId}`);
    console.log(`Expires In:   ${data.expiresIn} seconds (${data.expiresIn / 3600} hours)`);
    console.log(`Token Length: ${data.token.length} characters`);
    console.log(`Token Prefix: ${data.token.substring(0, 20)}...`);
    console.log(`Token Version: ${data.token.substring(0, 2)}`);
    console.log('───────────────────────────────────────────────────────\n');

    // Validate token format
    console.log('🔍 Validating Token Format...\n');
    
    const validations = [];
    
    // Check version
    if (data.token.startsWith('04')) {
      validations.push({ test: 'Version Flag', status: 'PASS', detail: 'Starts with "04"' });
    } else {
      validations.push({ test: 'Version Flag', status: 'FAIL', detail: `Starts with "${data.token.substring(0, 2)}" (should be "04")` });
    }

    // Check length
    if (data.token.length >= 300 && data.token.length <= 500) {
      validations.push({ test: 'Token Length', status: 'PASS', detail: `${data.token.length} chars (normal range)` });
    } else {
      validations.push({ test: 'Token Length', status: 'WARN', detail: `${data.token.length} chars (expected 300-500)` });
    }

    // Check base64 format after version
    const base64Part = data.token.substring(2);
    try {
      atob(base64Part);
      validations.push({ test: 'Base64 Format', status: 'PASS', detail: 'Valid base64 encoding' });
    } catch (e) {
      validations.push({ test: 'Base64 Format', status: 'FAIL', detail: 'Invalid base64 encoding' });
    }

    // Check App ID
    if (data.appID && data.appID > 0) {
      validations.push({ test: 'App ID', status: 'PASS', detail: `${data.appID}` });
    } else {
      validations.push({ test: 'App ID', status: 'FAIL', detail: 'Invalid or missing' });
    }

    // Check expiry
    if (data.expiresIn >= 3600) {
      validations.push({ test: 'Expiry Time', status: 'PASS', detail: `${data.expiresIn}s (${data.expiresIn / 3600}h)` });
    } else {
      validations.push({ test: 'Expiry Time', status: 'WARN', detail: `${data.expiresIn}s (less than 1 hour)` });
    }

    console.log('Validation Results:');
    console.log('───────────────────────────────────────────────────────');
    validations.forEach(v => {
      const icon = v.status === 'PASS' ? '✅' : (v.status === 'WARN' ? '⚠️' : '❌');
      console.log(`${icon} ${v.test.padEnd(20)} ${v.status.padEnd(5)} - ${v.detail}`);
    });
    console.log('───────────────────────────────────────────────────────\n');

    const allPassed = validations.every(v => v.status === 'PASS');
    
    if (allPassed) {
      console.log('🎉 All validations passed! Token format looks correct.\n');
      console.log('📝 Next Steps:');
      console.log('   1. Try joining a room with this token in your Flutter app');
      console.log('   2. Check for error 50119 in the logs');
      console.log('   3. If error persists, verify App ID and ServerSecret in ZEGO Console\n');
    } else {
      console.log('⚠️  Some validations failed. Please check the token generation logic.\n');
    }

    return allPassed;

  } catch (error) {
    console.error('❌ Test Failed:', error);
    return false;
  }
}

// Run the test
console.log('Starting test...\n');
testTokenGeneration().then((success) => {
  if (success) {
    console.log('═══════════════════════════════════════════════════════');
    console.log('✅ Token test completed successfully!');
    console.log('═══════════════════════════════════════════════════════\n');
    Deno.exit(0);
  } else {
    console.log('═══════════════════════════════════════════════════════');
    console.log('❌ Token test failed. Please check the errors above.');
    console.log('═══════════════════════════════════════════════════════\n');
    Deno.exit(1);
  }
});
