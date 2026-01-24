// supabase/functions/generate-zego-token/index.ts
// ZEGO Token 04 Generator - Using Official Algorithm (AES-GCM Encryption)
console.info('Zego Token Edge Function loaded - v4.0 (AES-GCM with HEX secret)');

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), { 
      status: 405, 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    });
  }

  try {
    const body = await req.json().catch(() => ({}));
    const { userId, roomId } = body as { userId?: string; roomId?: string };

    console.log('╔══════════════════════════════════════════════════════════════');
    console.log('║ 📥 ZEGO TOKEN REQUEST RECEIVED');
    console.log('╠══════════════════════════════════════════════════════════════');
    console.log(`║ userId: ${userId}`);
    console.log(`║ roomId: ${roomId}`);
    console.log('╚══════════════════════════════════════════════════════════════');

    if (!userId || typeof userId !== 'string') {
      console.error('❌ Missing userId');
      return new Response(JSON.stringify({ error: 'userId is required (string)' }), { 
        status: 400, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      });
    }

    // ZEGO credentials
    // The serverSecret from ZEGO Console is a 64-character HEX string
    // which represents 32 raw bytes for AES-256-GCM
    // Get from environment variable if available, otherwise use hardcoded value
    const appID = parseInt(Deno.env.get('ZEGO_APP_ID') || '424135686');
    const serverSecretHex = Deno.env.get('ZEGO_SERVER_SECRET') || 
      '5323ca723c6abb1ee6b55f38ee067aa21a1cd6351977d694e35650fb0814cdf9';
    const effectiveTimeInSeconds = 86400; // 24 hours
    
    // Validate serverSecretHex format
    if (serverSecretHex.length !== 64 || !/^[0-9a-fA-F]{64}$/.test(serverSecretHex)) {
      console.error('❌ Invalid serverSecretHex format - must be 64 hex characters');
      throw new Error('Invalid server secret format');
    }
    
    console.log('🔑 Generating ZEGO Token v04 (AES-GCM)...');
    console.log(`   appID: ${appID}`);
    console.log(`   secretHex length: ${serverSecretHex.length} chars (= 32 bytes)`);
    console.log(`   userId: ${userId}`);
    console.log(`   roomId: ${roomId || '(empty)'}`);
    console.log(`   effectiveTime: ${effectiveTimeInSeconds}s`);

    // Build payload for room privilege control
    // For basic usage without room-level privilege control, use empty payload
    // For room-level privilege, include room_id and privilege settings
    let payload = '';
    
    if (roomId && roomId.trim() !== '') {
      // Use room-level privilege when roomId is provided
      const payloadObject = {
        room_id: roomId,
        privilege: {
          1: 1,   // loginRoom: 1 = allow, 0 = deny
          2: 1    // publishStream: 1 = allow, 0 = deny
        },
        stream_id_list: null as null | string[]
      };
      payload = JSON.stringify(payloadObject);
      console.log(`   payload (room-level): ${payload}`);
    } else {
      console.log(`   payload: (empty - no room-level control)`);
    }

    // Generate token using ZEGO's official algorithm
    const token = await generateToken04(
      appID,
      userId,
      serverSecretHex,
      effectiveTimeInSeconds,
      payload
    );

    console.log('╔══════════════════════════════════════════════════════════════');
    console.log('║ ✅ TOKEN GENERATED SUCCESSFULLY');
    console.log('╠══════════════════════════════════════════════════════════════');
    console.log(`║ token length: ${token.length} chars`);
    console.log(`║ token prefix: ${token.substring(0, 20)}...`);
    console.log('╚══════════════════════════════════════════════════════════════');

    return new Response(
      JSON.stringify({ 
        token, 
        appID, 
        userId, 
        roomId: roomId || '',
        expiresIn: effectiveTimeInSeconds 
      }), 
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (err) {
    console.error('❌ Token generation error:', err);
    return new Response(JSON.stringify({ error: 'Failed to generate token', details: String(err) }), { 
      status: 500, 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    });
  }
});

/**
 * Convert hex string to Uint8Array
 */
function hexToBytes(hex: string): Uint8Array {
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < hex.length; i += 2) {
    bytes[i / 2] = parseInt(hex.substring(i, i + 2), 16);
  }
  return bytes;
}

/**
 * Generate ZEGO Token 04 using AES-GCM encryption
 * Based on official ZEGO server assistant algorithm from:
 * https://github.com/zegoim/zego_server_assistant/tree/main/token/nodejs/token04
 */
async function generateToken04(
  appId: number,
  userId: string,
  secretHex: string,
  effectiveTimeInSeconds: number,
  payload: string
): Promise<string> {
  const VERSION_FLAG = '04';
  
  const createTime = Math.floor(Date.now() / 1000);
  const expireTime = createTime + effectiveTimeInSeconds;
  const nonce = makeNonce();

  // Token info structure - must match ZEGO's expected format exactly
  const tokenInfo = {
    app_id: appId,
    user_id: userId,
    nonce: nonce,
    ctime: createTime,
    expire: expireTime,
    payload: payload
  };

  const plainText = JSON.stringify(tokenInfo);
  console.log('   tokenInfo:');
  console.log(`     - app_id: ${tokenInfo.app_id}`);
  console.log(`     - user_id: ${tokenInfo.user_id}`);
  console.log(`     - nonce: ${tokenInfo.nonce}`);
  console.log(`     - created: ${new Date(createTime * 1000).toISOString()}`);
  console.log(`     - expires: ${new Date(expireTime * 1000).toISOString()}`);
  console.log(`     - payload length: ${payload.length} chars`);

  // Convert hex secret to raw bytes (32 bytes = 256 bits for AES-256-GCM)
  const secretBytes = hexToBytes(secretHex);
  console.log(`   secretBytes length: ${secretBytes.length} bytes`);

  // AES-GCM encryption
  const { encryptBuf, iv } = await aesGcmEncrypt(plainText, secretBytes);
  
  console.log(`   IV length: ${iv.length} bytes`);
  console.log(`   Encrypted length: ${encryptBuf.length} bytes`);
  
  // Build token binary structure
  // Format: expire(8 bytes BE) + iv_len(2 bytes BE) + iv + encrypted_len(2 bytes BE) + encrypted + mode(1 byte)
  const expireBytes = new Uint8Array(8);
  const expireView = new DataView(expireBytes.buffer);
  // Write expire time as 64-bit big-endian integer
  // JavaScript's bitwise operations work on 32-bit signed integers, so we need to handle 64-bit carefully
  const high = Math.floor(expireTime / 4294967296); // divide by 2^32
  const low = expireTime >>> 0; // convert to unsigned 32-bit
  expireView.setUint32(0, high, false); // high 32 bits, big-endian
  expireView.setUint32(4, low, false); // low 32 bits, big-endian
  
  const ivLenBytes = new Uint8Array(2);
  new DataView(ivLenBytes.buffer).setUint16(0, iv.length, false);
  
  const encryptLenBytes = new Uint8Array(2);
  new DataView(encryptLenBytes.buffer).setUint16(0, encryptBuf.length, false);
  
  const modeBytes = new Uint8Array([1]); // 1 = GCM mode
  
  // Concatenate all parts
  const totalLen = 8 + 2 + iv.length + 2 + encryptBuf.length + 1;
  const tokenBuffer = new Uint8Array(totalLen);
  let offset = 0;
  
  tokenBuffer.set(expireBytes, offset); offset += 8;
  tokenBuffer.set(ivLenBytes, offset); offset += 2;
  tokenBuffer.set(iv, offset); offset += iv.length;
  tokenBuffer.set(encryptLenBytes, offset); offset += 2;
  tokenBuffer.set(encryptBuf, offset); offset += encryptBuf.length;
  tokenBuffer.set(modeBytes, offset);
  
  console.log(`   Total token buffer length: ${totalLen} bytes`);
  
  // Base64 encode and prepend version flag
  const base64Token = btoa(String.fromCharCode(...tokenBuffer));
  
  return VERSION_FLAG + base64Token;
}

/**
 * Generate random nonce in int32 range
 */
function makeNonce(): number {
  const min = -2147483648; // -2^31
  const max = 2147483647;  // 2^31 - 1
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

/**
 * AES-GCM encryption with 12-byte IV
 * Uses raw bytes for the key (32 bytes = 256 bits)
 * Note: AES-GCM automatically appends a 16-byte authentication tag to the ciphertext
 */
async function aesGcmEncrypt(
  plainText: string, 
  keyBytes: Uint8Array
): Promise<{ encryptBuf: Uint8Array; iv: Uint8Array }> {
  const encoder = new TextEncoder();
  
  // Generate 12-byte IV (recommended for GCM mode)
  const iv = crypto.getRandomValues(new Uint8Array(12));
  
  // Import key - keyBytes must be 32 bytes (256 bits) for AES-256-GCM
  const cryptoKey = await crypto.subtle.importKey(
    'raw',
    keyBytes,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt']
  );
  
  // Encrypt - the result includes the ciphertext + 16-byte authentication tag
  const plainBytes = encoder.encode(plainText);
  const encryptedBuffer = await crypto.subtle.encrypt(
    { 
      name: 'AES-GCM', 
      iv: iv,
      tagLength: 128 // 128 bits = 16 bytes tag
    },
    cryptoKey,
    plainBytes
  );
  
  // The encryptedBuffer contains: ciphertext + tag (16 bytes)
  return {
    encryptBuf: new Uint8Array(encryptedBuffer),
    iv: iv
  };
}
