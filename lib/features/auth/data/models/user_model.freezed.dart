// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  @JsonKey(name: 'id')
  String get uid => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_url')
  String? get photoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_of_birth')
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_verified')
  bool get isVerified => throw _privateConstructorUsedError;
  int get coins => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  @JsonKey(name: 'vip_until')
  DateTime? get vipUntil => throw _privateConstructorUsedError;
  @JsonKey(name: 'lifetime_gifts_value')
  int get lifetimeGiftsValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'monthly_gifts_value')
  int get monthlyGiftsValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'followers_count')
  int get followersCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'following_count')
  int get followingCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'blocked_users')
  List<String> get blockedUsers => throw _privateConstructorUsedError;
  @JsonKey(name: 'report_count')
  int get reportCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_banned')
  bool get isBanned => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String uid,
      String? name,
      String? email,
      String? phone,
      @JsonKey(name: 'photo_url') String? photoUrl,
      @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
      @JsonKey(name: 'is_verified') bool isVerified,
      int coins,
      int level,
      @JsonKey(name: 'vip_until') DateTime? vipUntil,
      @JsonKey(name: 'lifetime_gifts_value') int lifetimeGiftsValue,
      @JsonKey(name: 'monthly_gifts_value') int monthlyGiftsValue,
      @JsonKey(name: 'followers_count') int followersCount,
      @JsonKey(name: 'following_count') int followingCount,
      @JsonKey(name: 'blocked_users') List<String> blockedUsers,
      @JsonKey(name: 'report_count') int reportCount,
      @JsonKey(name: 'is_banned') bool isBanned,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? name = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? photoUrl = freezed,
    Object? dateOfBirth = freezed,
    Object? isVerified = null,
    Object? coins = null,
    Object? level = null,
    Object? vipUntil = freezed,
    Object? lifetimeGiftsValue = null,
    Object? monthlyGiftsValue = null,
    Object? followersCount = null,
    Object? followingCount = null,
    Object? blockedUsers = null,
    Object? reportCount = null,
    Object? isBanned = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      coins: null == coins
          ? _value.coins
          : coins // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      vipUntil: freezed == vipUntil
          ? _value.vipUntil
          : vipUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lifetimeGiftsValue: null == lifetimeGiftsValue
          ? _value.lifetimeGiftsValue
          : lifetimeGiftsValue // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyGiftsValue: null == monthlyGiftsValue
          ? _value.monthlyGiftsValue
          : monthlyGiftsValue // ignore: cast_nullable_to_non_nullable
              as int,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
      blockedUsers: null == blockedUsers
          ? _value.blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reportCount: null == reportCount
          ? _value.reportCount
          : reportCount // ignore: cast_nullable_to_non_nullable
              as int,
      isBanned: null == isBanned
          ? _value.isBanned
          : isBanned // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String uid,
      String? name,
      String? email,
      String? phone,
      @JsonKey(name: 'photo_url') String? photoUrl,
      @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
      @JsonKey(name: 'is_verified') bool isVerified,
      int coins,
      int level,
      @JsonKey(name: 'vip_until') DateTime? vipUntil,
      @JsonKey(name: 'lifetime_gifts_value') int lifetimeGiftsValue,
      @JsonKey(name: 'monthly_gifts_value') int monthlyGiftsValue,
      @JsonKey(name: 'followers_count') int followersCount,
      @JsonKey(name: 'following_count') int followingCount,
      @JsonKey(name: 'blocked_users') List<String> blockedUsers,
      @JsonKey(name: 'report_count') int reportCount,
      @JsonKey(name: 'is_banned') bool isBanned,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? name = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? photoUrl = freezed,
    Object? dateOfBirth = freezed,
    Object? isVerified = null,
    Object? coins = null,
    Object? level = null,
    Object? vipUntil = freezed,
    Object? lifetimeGiftsValue = null,
    Object? monthlyGiftsValue = null,
    Object? followersCount = null,
    Object? followingCount = null,
    Object? blockedUsers = null,
    Object? reportCount = null,
    Object? isBanned = null,
    Object? createdAt = null,
  }) {
    return _then(_$UserModelImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      coins: null == coins
          ? _value.coins
          : coins // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      vipUntil: freezed == vipUntil
          ? _value.vipUntil
          : vipUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lifetimeGiftsValue: null == lifetimeGiftsValue
          ? _value.lifetimeGiftsValue
          : lifetimeGiftsValue // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyGiftsValue: null == monthlyGiftsValue
          ? _value.monthlyGiftsValue
          : monthlyGiftsValue // ignore: cast_nullable_to_non_nullable
              as int,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
      blockedUsers: null == blockedUsers
          ? _value._blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reportCount: null == reportCount
          ? _value.reportCount
          : reportCount // ignore: cast_nullable_to_non_nullable
              as int,
      isBanned: null == isBanned
          ? _value.isBanned
          : isBanned // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl(
      {@JsonKey(name: 'id') required this.uid,
      this.name,
      this.email,
      this.phone,
      @JsonKey(name: 'photo_url') this.photoUrl,
      @JsonKey(name: 'date_of_birth') this.dateOfBirth,
      @JsonKey(name: 'is_verified') this.isVerified = false,
      this.coins = 0,
      this.level = 1,
      @JsonKey(name: 'vip_until') this.vipUntil,
      @JsonKey(name: 'lifetime_gifts_value') this.lifetimeGiftsValue = 0,
      @JsonKey(name: 'monthly_gifts_value') this.monthlyGiftsValue = 0,
      @JsonKey(name: 'followers_count') this.followersCount = 0,
      @JsonKey(name: 'following_count') this.followingCount = 0,
      @JsonKey(name: 'blocked_users')
      final List<String> blockedUsers = const [],
      @JsonKey(name: 'report_count') this.reportCount = 0,
      @JsonKey(name: 'is_banned') this.isBanned = false,
      @JsonKey(name: 'created_at') required this.createdAt})
      : _blockedUsers = blockedUsers,
        super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String uid;
  @override
  final String? name;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  @override
  @JsonKey(name: 'date_of_birth')
  final DateTime? dateOfBirth;
  @override
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @override
  @JsonKey()
  final int coins;
  @override
  @JsonKey()
  final int level;
  @override
  @JsonKey(name: 'vip_until')
  final DateTime? vipUntil;
  @override
  @JsonKey(name: 'lifetime_gifts_value')
  final int lifetimeGiftsValue;
  @override
  @JsonKey(name: 'monthly_gifts_value')
  final int monthlyGiftsValue;
  @override
  @JsonKey(name: 'followers_count')
  final int followersCount;
  @override
  @JsonKey(name: 'following_count')
  final int followingCount;
  final List<String> _blockedUsers;
  @override
  @JsonKey(name: 'blocked_users')
  List<String> get blockedUsers {
    if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blockedUsers);
  }

  @override
  @JsonKey(name: 'report_count')
  final int reportCount;
  @override
  @JsonKey(name: 'is_banned')
  final bool isBanned;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, phone: $phone, photoUrl: $photoUrl, dateOfBirth: $dateOfBirth, isVerified: $isVerified, coins: $coins, level: $level, vipUntil: $vipUntil, lifetimeGiftsValue: $lifetimeGiftsValue, monthlyGiftsValue: $monthlyGiftsValue, followersCount: $followersCount, followingCount: $followingCount, blockedUsers: $blockedUsers, reportCount: $reportCount, isBanned: $isBanned, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.coins, coins) || other.coins == coins) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.vipUntil, vipUntil) ||
                other.vipUntil == vipUntil) &&
            (identical(other.lifetimeGiftsValue, lifetimeGiftsValue) ||
                other.lifetimeGiftsValue == lifetimeGiftsValue) &&
            (identical(other.monthlyGiftsValue, monthlyGiftsValue) ||
                other.monthlyGiftsValue == monthlyGiftsValue) &&
            (identical(other.followersCount, followersCount) ||
                other.followersCount == followersCount) &&
            (identical(other.followingCount, followingCount) ||
                other.followingCount == followingCount) &&
            const DeepCollectionEquality()
                .equals(other._blockedUsers, _blockedUsers) &&
            (identical(other.reportCount, reportCount) ||
                other.reportCount == reportCount) &&
            (identical(other.isBanned, isBanned) ||
                other.isBanned == isBanned) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
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
      const DeepCollectionEquality().hash(_blockedUsers),
      reportCount,
      isBanned,
      createdAt);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel(
          {@JsonKey(name: 'id') required final String uid,
          final String? name,
          final String? email,
          final String? phone,
          @JsonKey(name: 'photo_url') final String? photoUrl,
          @JsonKey(name: 'date_of_birth') final DateTime? dateOfBirth,
          @JsonKey(name: 'is_verified') final bool isVerified,
          final int coins,
          final int level,
          @JsonKey(name: 'vip_until') final DateTime? vipUntil,
          @JsonKey(name: 'lifetime_gifts_value') final int lifetimeGiftsValue,
          @JsonKey(name: 'monthly_gifts_value') final int monthlyGiftsValue,
          @JsonKey(name: 'followers_count') final int followersCount,
          @JsonKey(name: 'following_count') final int followingCount,
          @JsonKey(name: 'blocked_users') final List<String> blockedUsers,
          @JsonKey(name: 'report_count') final int reportCount,
          @JsonKey(name: 'is_banned') final bool isBanned,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get uid;
  @override
  String? get name;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  @JsonKey(name: 'photo_url')
  String? get photoUrl;
  @override
  @JsonKey(name: 'date_of_birth')
  DateTime? get dateOfBirth;
  @override
  @JsonKey(name: 'is_verified')
  bool get isVerified;
  @override
  int get coins;
  @override
  int get level;
  @override
  @JsonKey(name: 'vip_until')
  DateTime? get vipUntil;
  @override
  @JsonKey(name: 'lifetime_gifts_value')
  int get lifetimeGiftsValue;
  @override
  @JsonKey(name: 'monthly_gifts_value')
  int get monthlyGiftsValue;
  @override
  @JsonKey(name: 'followers_count')
  int get followersCount;
  @override
  @JsonKey(name: 'following_count')
  int get followingCount;
  @override
  @JsonKey(name: 'blocked_users')
  List<String> get blockedUsers;
  @override
  @JsonKey(name: 'report_count')
  int get reportCount;
  @override
  @JsonKey(name: 'is_banned')
  bool get isBanned;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
