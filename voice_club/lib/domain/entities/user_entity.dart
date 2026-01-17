import 'package:equatable/equatable.dart';

enum LegendLevel { none, level1, level2, level3, level4, level5 }

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final DateTime createdAt;
  final bool isVerified;

  // Coins & Wallet
  final int coins;
  final int totalCoinsEarned;
  final int totalCoinsSpent;

  // VIP & Legend
  final bool isVIP;
  final DateTime? vipExpiryDate;
  final LegendLevel legendLevel;
  final int totalGiftsReceived;
  final int totalGiftsSent;

  // Stats
  final int roomsHosted;
  final int roomsJoined;
  final int totalListeningHours;

  const UserEntity({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.createdAt,
    this.isVerified = false,
    this.coins = 0,
    this.totalCoinsEarned = 0,
    this.totalCoinsSpent = 0,
    this.isVIP = false,
    this.vipExpiryDate,
    this.legendLevel = LegendLevel.none,
    this.totalGiftsReceived = 0,
    this.totalGiftsSent = 0,
    this.roomsHosted = 0,
    this.roomsJoined = 0,
    this.totalListeningHours = 0,
  });

  bool get hasActiveVIP {
    if (!isVIP || vipExpiryDate == null) return false;
    return vipExpiryDate!.isAfter(DateTime.now());
  }

  String get legendLevelName {
    switch (legendLevel) {
      case LegendLevel.none:
        return 'Member';
      case LegendLevel.level1:
        return 'Bronze Legend';
      case LegendLevel.level2:
        return 'Silver Legend';
      case LegendLevel.level3:
        return 'Gold Legend';
      case LegendLevel.level4:
        return 'Platinum Legend';
      case LegendLevel.level5:
        return 'Diamond Legend';
    }
  }

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    avatarUrl,
    bio,
    followersCount,
    followingCount,
    createdAt,
    isVerified,
    coins,
    totalCoinsEarned,
    totalCoinsSpent,
    isVIP,
    vipExpiryDate,
    legendLevel,
    totalGiftsReceived,
    totalGiftsSent,
    roomsHosted,
    roomsJoined,
    totalListeningHours,
  ];
}
