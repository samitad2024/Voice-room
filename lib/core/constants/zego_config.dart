/// Zego Cloud Configuration
/// IMPORTANT: Never expose AppSign in client code
/// Tokens must be generated server-side via Edge Functions
class ZegoConfig {
  // Zego App ID from console
  static const int appID = 424135686;

  // DO NOT store AppSign here! Generate tokens server-side
  // static const String appSign = ''; // NEVER STORE THIS

  // Audio settings
  static const int standardBitrate = 48; // kbps - standard quality
  static const int highBitrate = 96; // kbps - high quality for VIP

  // Room capacity
  static const int maxSpeakers = 20;
  static const int maxListeners = 500;

  // Reconnection strategy
  static const List<int> reconnectDelays = [1000, 2000, 4000, 8000]; // ms

  // Network quality thresholds
  static const int excellentQuality = 0; // 0-1
  static const int goodQuality = 2; // 2-3
  static const int poorQuality = 4; // 4-6

  ZegoConfig._();
}
