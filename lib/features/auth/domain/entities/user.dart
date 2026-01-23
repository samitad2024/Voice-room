import 'package:equatable/equatable.dart';

/// User entity - domain model
class User extends Equatable {
  final String uid;
  final String? name;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final DateTime? dateOfBirth;
  final bool isVerified;
  final int coins;
  final int level;
  final DateTime? vipUntil;
  final int lifetimeGiftsValue;
  final int monthlyGiftsValue;
  final int followersCount;
  final int followingCount;
  final List<String> blockedUsers;
  final int reportCount;
  final bool isBanned;
  final DateTime createdAt;

  const User({
    required this.uid,
    this.name,
    this.email,
    this.phone,
    this.photoUrl,
    this.dateOfBirth,
    this.isVerified = false,
    this.coins = 0,
    this.level = 1,
    this.vipUntil,
    this.lifetimeGiftsValue = 0,
    this.monthlyGiftsValue = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.blockedUsers = const [],
    this.reportCount = 0,
    this.isBanned = false,
    required this.createdAt,
  });

  bool get isVip {
    if (vipUntil == null) return false;
    return vipUntil!.isAfter(DateTime.now());
  }

  bool get isAgeVerified => dateOfBirth != null;

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        phone,
        photoUrl,
        dateOfBirth,
        isVerified,
        coins,
        level,
        vipUntil,
        lifetimeGiftsValue,
        monthlyGiftsValue,
        followersCount,
        followingCount,
        blockedUsers,
        reportCount,
        isBanned,
        createdAt,
      ];
}
