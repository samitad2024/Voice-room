import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.fullName,
    super.avatarUrl,
    super.bio,
    required super.followersCount,
    required super.followingCount,
    required super.createdAt,
    super.isVerified,
    super.coins,
    super.totalCoinsEarned,
    super.totalCoinsSpent,
    super.isVIP,
    super.vipExpiryDate,
    super.legendLevel,
    super.totalGiftsReceived,
    super.totalGiftsSent,
    super.roomsHosted,
    super.roomsJoined,
    super.totalListeningHours,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      followersCount: json['followersCount'] as int,
      followingCount: json['followingCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
      coins: json['coins'] as int? ?? 0,
      totalCoinsEarned: json['totalCoinsEarned'] as int? ?? 0,
      totalCoinsSpent: json['totalCoinsSpent'] as int? ?? 0,
      isVIP: json['isVIP'] as bool? ?? false,
      vipExpiryDate: json['vipExpiryDate'] != null
          ? DateTime.parse(json['vipExpiryDate'] as String)
          : null,
      legendLevel: _legendLevelFromString(json['legendLevel'] as String?),
      totalGiftsReceived: json['totalGiftsReceived'] as int? ?? 0,
      totalGiftsSent: json['totalGiftsSent'] as int? ?? 0,
      roomsHosted: json['roomsHosted'] as int? ?? 0,
      roomsJoined: json['roomsJoined'] as int? ?? 0,
      totalListeningHours: json['totalListeningHours'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
      'coins': coins,
      'totalCoinsEarned': totalCoinsEarned,
      'totalCoinsSpent': totalCoinsSpent,
      'isVIP': isVIP,
      'vipExpiryDate': vipExpiryDate?.toIso8601String(),
      'legendLevel': _legendLevelToString(legendLevel),
      'totalGiftsReceived': totalGiftsReceived,
      'totalGiftsSent': totalGiftsSent,
      'roomsHosted': roomsHosted,
      'roomsJoined': roomsJoined,
      'totalListeningHours': totalListeningHours,
    };
  }

  static LegendLevel _legendLevelFromString(String? level) {
    switch (level) {
      case 'level1':
        return LegendLevel.level1;
      case 'level2':
        return LegendLevel.level2;
      case 'level3':
        return LegendLevel.level3;
      case 'level4':
        return LegendLevel.level4;
      case 'level5':
        return LegendLevel.level5;
      default:
        return LegendLevel.none;
    }
  }

  static String _legendLevelToString(LegendLevel level) {
    switch (level) {
      case LegendLevel.none:
        return 'none';
      case LegendLevel.level1:
        return 'level1';
      case LegendLevel.level2:
        return 'level2';
      case LegendLevel.level3:
        return 'level3';
      case LegendLevel.level4:
        return 'level4';
      case LegendLevel.level5:
        return 'level5';
    }
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      fullName: fullName,
      avatarUrl: avatarUrl,
      bio: bio,
      followersCount: followersCount,
      followingCount: followingCount,
      createdAt: createdAt,
      isVerified: isVerified,
      coins: coins,
      totalCoinsEarned: totalCoinsEarned,
      totalCoinsSpent: totalCoinsSpent,
      isVIP: isVIP,
      vipExpiryDate: vipExpiryDate,
      legendLevel: legendLevel,
      totalGiftsReceived: totalGiftsReceived,
      totalGiftsSent: totalGiftsSent,
      roomsHosted: roomsHosted,
      roomsJoined: roomsJoined,
      totalListeningHours: totalListeningHours,
    );
  }
}
