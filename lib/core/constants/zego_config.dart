/// Zego Cloud Configuration for Prebuilt Live Audio Room UIKit
/// Updated: January 30, 2026
class ZegoConfig {
  // Zego App ID from console (NEW CREDENTIALS)
  static const int appID = 1434265091;

  // App Sign for token generation (used in Prebuilt UIKit)
  static const String appSign =
      'c0521ffb2b89cc4ed257fda942aa4279318e972063bdc1d5257eb935929a5942';

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
