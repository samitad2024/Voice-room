/// Supabase configuration for the Social Voice app
///
/// Contains project URL and API keys for connecting to Supabase backend
class SupabaseConfig {
  /// Supabase project URL
  static const String projectUrl = 'https://dshtknsycapihbehvxnv.supabase.co';

  /// Publishable API key (anon key) - safe to use in client
  /// Protected by Row Level Security (RLS) policies
  /// Get this from: Supabase Dashboard > Settings > API > Publishable API Key
  static const String anonKey =
      'sb_publishable_Y_hXYwmd3CUSxlImw5Cu5g_DBJZGP1j';

  /// Stream URL for Realtime subscriptions (optional, auto-generated from projectUrl)
  static String get realtimeUrl =>
      projectUrl.replaceFirst('https://', 'wss://');

  /// Storage URL for file uploads
  static String get storageUrl => '$projectUrl/storage/v1';

  // Note: Never expose the service_role key in client code!
  // Service role key should only be used in Edge Functions or secure backend
}
