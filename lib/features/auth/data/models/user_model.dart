import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    @JsonKey(name: 'id') required String uid,
    String? name,
    String? email,
    String? phone,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    @Default(false) @JsonKey(name: 'is_verified') bool isVerified,
    @Default(0) int coins,
    @Default(1) int level,
    @JsonKey(name: 'vip_until') DateTime? vipUntil,
    @Default(0) @JsonKey(name: 'lifetime_gifts_value') int lifetimeGiftsValue,
    @Default(0) @JsonKey(name: 'monthly_gifts_value') int monthlyGiftsValue,
    @Default(0) @JsonKey(name: 'followers_count') int followersCount,
    @Default(0) @JsonKey(name: 'following_count') int followingCount,
    @Default([]) @JsonKey(name: 'blocked_users') List<String> blockedUsers,
    @Default(0) @JsonKey(name: 'report_count') int reportCount,
    @Default(false) @JsonKey(name: 'is_banned') bool isBanned,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  User toEntity() {
    return User(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
      dateOfBirth: dateOfBirth,
      isVerified: isVerified,
      coins: coins,
      level: level,
      vipUntil: vipUntil,
      lifetimeGiftsValue: lifetimeGiftsValue,
      monthlyGiftsValue: monthlyGiftsValue,
      followersCount: followersCount,
      followingCount: followingCount,
      blockedUsers: blockedUsers,
      reportCount: reportCount,
      isBanned: isBanned,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      phone: user.phone,
      photoUrl: user.photoUrl,
      dateOfBirth: user.dateOfBirth,
      isVerified: user.isVerified,
      coins: user.coins,
      level: user.level,
      vipUntil: user.vipUntil,
      lifetimeGiftsValue: user.lifetimeGiftsValue,
      monthlyGiftsValue: user.monthlyGiftsValue,
      followersCount: user.followersCount,
      followingCount: user.followingCount,
      blockedUsers: user.blockedUsers,
      reportCount: user.reportCount,
      isBanned: user.isBanned,
      createdAt: user.createdAt,
    );
  }
}
