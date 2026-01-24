import 'package:equatable/equatable.dart';

/// Live room participant entity
/// Represents real-time state of a participant in a room
/// Synced via Supabase Realtime subscriptions
class LiveRoomParticipant extends Equatable {
  final String roomId;
  final String userId;
  final String role; // 'owner', 'admin', 'speaker', 'audience'
  final bool isMuted;
  final bool isOnline;
  final String networkQuality; // 'excellent', 'good', 'poor'
  final DateTime lastSeen;

  // User info (joined from users table)
  final String? userName;
  final String? userPhotoUrl;
  final int? userLevel;
  final bool? userIsVerified;

  const LiveRoomParticipant({
    required this.roomId,
    required this.userId,
    this.role = 'audience',
    this.isMuted = false,
    this.isOnline = true,
    this.networkQuality = 'good',
    required this.lastSeen,
    this.userName,
    this.userPhotoUrl,
    this.userLevel,
    this.userIsVerified,
  });

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';
  bool get isSpeaker => role == 'speaker';
  bool get isAudience => role == 'audience';
  bool get canSpeak => isOwner || isAdmin || isSpeaker;
  bool get canModerate => isOwner || isAdmin;
  bool get hasGoodConnection => networkQuality != 'poor';

  @override
  List<Object?> get props => [
        roomId,
        userId,
        role,
        isMuted,
        isOnline,
        networkQuality,
        lastSeen,
        userName,
        userPhotoUrl,
        userLevel,
        userIsVerified,
      ];

  /// Create from JSON
  factory LiveRoomParticipant.fromJson(Map<String, dynamic> json) {
    return LiveRoomParticipant(
      roomId: json['room_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'audience',
      isMuted: json['is_muted'] as bool? ?? false,
      isOnline: json['is_online'] as bool? ?? true,
      networkQuality: json['network_quality'] as String? ?? 'good',
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : DateTime.now(),
      userName: json['user_name'] as String?,
      userPhotoUrl: json['user_photo_url'] as String?,
      userLevel: json['user_level'] as int?,
      userIsVerified: json['user_is_verified'] as bool?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'user_id': userId,
      'role': role,
      'is_muted': isMuted,
      'is_online': isOnline,
      'network_quality': networkQuality,
      'last_seen': lastSeen.toIso8601String(),
      if (userName != null) 'user_name': userName,
      if (userPhotoUrl != null) 'user_photo_url': userPhotoUrl,
      if (userLevel != null) 'user_level': userLevel,
      if (userIsVerified != null) 'user_is_verified': userIsVerified,
    };
  }

  /// Create a copy with modified fields
  LiveRoomParticipant copyWith({
    String? roomId,
    String? userId,
    String? role,
    bool? isMuted,
    bool? isOnline,
    String? networkQuality,
    DateTime? lastSeen,
    String? userName,
    String? userPhotoUrl,
    int? userLevel,
    bool? userIsVerified,
  }) {
    return LiveRoomParticipant(
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      isMuted: isMuted ?? this.isMuted,
      isOnline: isOnline ?? this.isOnline,
      networkQuality: networkQuality ?? this.networkQuality,
      lastSeen: lastSeen ?? this.lastSeen,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      userLevel: userLevel ?? this.userLevel,
      userIsVerified: userIsVerified ?? this.userIsVerified,
    );
  }
}
