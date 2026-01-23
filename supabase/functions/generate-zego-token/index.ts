// supabase/functions/generate-zego-token/index.ts
console.info('Zego Token Edge Function loaded');

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

    if (!userId || typeof userId !== 'string') {
      return new Response(JSON.stringify({ error: 'userId is required (string)' }), { 
        status: 400, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      });
    }

    // ZEGO credentials - hardcoded
    const appID = 424135686;
    // IMPORTANT: Use ServerSecret (NOT AppSign) from Zego Console
    const serverSecret = '5323ca723c6abb1ee6b55f38ee067aa21a1cd6351977d694e35650fb0814cdf9';

    if (!appID || !serverSecret) {
      console.error('Missing ZEGO credentials');
      return new Response(JSON.stringify({ error: 'Server config error' }), { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      });
    }

    const effectiveTimeInSeconds = 86400; // 24 hours (max recommended)
    const timestamp = Math.floor(Date.now() / 1000);
    const nonce = Math.floor(Math.random() * 2147483647);

    // ZEGO Token V4 Format - must match exactly
    const payload = {
      ver: 4,
      appid: appID,
      user_id: userId,
      room_id: roomId || '',
      privilege: {
        1: 1,  // Login privilege (required)
        2: 1   // Publish stream privilege (required for speakers)
      },
      stream_id_list: null, // null = can publish any stream
      nonce: nonce,
      ctime: timestamp,
      expire: timestamp + effectiveTimeInSeconds
    };

    // Base64url encoding helper
    const base64url = (buffer: Uint8Array): string => {
      const binary = String.fromCharCode(...buffer);
      const base64 = globalThis.btoa(binary);
      return base64.replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
    };

    const encoder = new TextEncoder();
    
    // Encode header and payload
    const headerStr = JSON.stringify({ alg: 'HS256', typ: 'JWT' });
    const payloadStr = JSON.stringify(payload);
    
    
    const headerB64 = base64url(encoder.encode(headerStr));
    const payloadB64 = base64url(encoder.encode(payloadStr));
    const unsignedToken = `${headerB64}.${payloadB64}`;

    // HMAC-SHA256 signature
    const key = await crypto.subtle.importKey(
      'raw', 
      encoder.encode(serverSecret), 
      { name: 'HMAC', hash: 'SHA-256' }, 
      false, 
      ['sign']
    );
    const signature = await crypto.subtle.sign('HMAC', key, encoder.encode(unsignedToken));
    const signatureB64 = base64url(new Uint8Array(signature));

    // ZEGO token format: "04" + base64(header.payload.signature)
    // The "04" prefix indicates token version 4
    const jwtToken = `${unsignedToken}.${signatureB64}`;
    const token = `04${globalThis.btoa(jwtToken).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')}`;

    console.log(`✅ Token generated successfully`);
    console.log(`   userId: ${userId}`);
    console.log(`   roomId: ${roomId || '(none)'}`);
    console.log(`   expires in: ${effectiveTimeInSeconds}s (${effectiveTimeInSeconds/3600}h)`);
    console.log(`   token length: ${token.length} chars`);

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
    console.error('Token error:', err);
    return new Response(JSON.stringify({ error: 'Failed to generate token' }), { 
      status: 500, 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    });
  }
});
