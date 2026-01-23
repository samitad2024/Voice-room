class AppConstants {
  // App Info
  static const String appName = 'Social Voice';
  static const String appVersion = '1.0.0';

  // API Endpoints (will be configured via Supabase)
  static const String baseUrl = 'https://api.socialvoice.app';

  // Google OAuth Configuration
  // TODO: Replace with your actual Google OAuth client ID from Google Cloud Console
  static const String googleClientId =
      'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com';

  // Zego Configuration (Add your credentials later)
  static const int zegoAppId = 0; // TODO: Add your Zego App ID
  static const String zegoAppSign = ''; // TODO: Add your Zego App Sign

  // Room Configuration
  static const int maxSpeakersPerRoom = 20;
  static const int maxListenersPerRoom = 500;
  static const int speakerRequestTimeout = 300; // 5 minutes in seconds
  static const int maxSpeakerRequests = 3;

  // Audio Configuration
  static const int audioBitrateStandard = 48; // kbps
  static const int audioBitrateHigh = 96; // kbps for VIP

  // Age Verification
  static const int minimumAge = 13;

  // Coin Packages
  static const Map<String, int> coinPackages = {
    'small': 100,
    'medium': 500,
    'large': 2000,
    'mega': 10000,
  };

  // VIP Configuration
  static const double vipMonthlyPrice = 9.99;
  static const int vipMonthlyCoins = 1000;

  // Level Thresholds (based on monthly gifts received)
  static const Map<int, int> levelThresholds = {
    1: 0, // Bronze
    2: 1000, // Silver
    3: 5000, // Gold
    4: 20000, // Platinum
    5: 100000, // Diamond (Legend)
  };

  // Gift Platform Fee
  static const double platformFeePercentage = 0.30; // 30%
  static const double creatorSharePercentage = 0.70; // 70%

  // Timeouts
  static const int connectionTimeout = 30; // seconds
  static const int zegoTokenExpiry = 86400; // 24 hours in seconds

  // Pagination
  static const int roomsPerPage = 20;
  static const int usersPerPage = 50;
  static const int transactionsPerPage = 50;

  // Report System
  static const int autobanReportCount = 10;

  // Storage
  static const String profileImagesPath = 'profile_images';
  static const String roomImagesPath = 'room_images';
  static const String giftAnimationsPath = 'gift_animations';

  // Shared Preferences Keys
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyUserId = 'user_id';
  static const String keyUserToken = 'user_token';
}
