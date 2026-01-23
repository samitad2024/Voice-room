// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      uid: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      photoUrl: json['photo_url'] as String?,
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
      isVerified: json['is_verified'] as bool? ?? false,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      vipUntil: json['vip_until'] == null
          ? null
          : DateTime.parse(json['vip_until'] as String),
      lifetimeGiftsValue: (json['lifetime_gifts_value'] as num?)?.toInt() ?? 0,
      monthlyGiftsValue: (json['monthly_gifts_value'] as num?)?.toInt() ?? 0,
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      blockedUsers: (json['blocked_users'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      reportCount: (json['report_count'] as num?)?.toInt() ?? 0,
      isBanned: json['is_banned'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'photo_url': instance.photoUrl,
      'date_of_birth': instance.dateOfBirth?.toIso8601String(),
      'is_verified': instance.isVerified,
      'coins': instance.coins,
      'level': instance.level,
      'vip_until': instance.vipUntil?.toIso8601String(),
      'lifetime_gifts_value': instance.lifetimeGiftsValue,
      'monthly_gifts_value': instance.monthlyGiftsValue,
      'followers_count': instance.followersCount,
      'following_count': instance.followingCount,
      'blocked_users': instance.blockedUsers,
      'report_count': instance.reportCount,
      'is_banned': instance.isBanned,
      'created_at': instance.createdAt.toIso8601String(),
    };
