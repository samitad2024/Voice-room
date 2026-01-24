import '../../domain/entities/live_room_participant.dart';

/// Model for live room participant with JSON serialization
class LiveRoomParticipantModel extends LiveRoomParticipant {
  const LiveRoomParticipantModel({
    required super.roomId,
    required super.userId,
    super.role = 'audience',
    super.isMuted = false,
    super.isOnline = true,
    super.networkQuality = 'good',
    required super.lastSeen,
    super.userName,
    super.userPhotoUrl,
    super.userLevel,
    super.userIsVerified,
  });

  /// Create from Supabase JSON response
  factory LiveRoomParticipantModel.fromJson(Map<String, dynamic> json) {
    // Handle joined user data if present
    final userData = json['users'] as Map<String, dynamic>?;

    return LiveRoomParticipantModel(
      roomId: json['room_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'audience',
      isMuted: json['is_muted'] as bool? ?? false,
      isOnline: json['is_online'] as bool? ?? true,
      networkQuality: json['network_quality'] as String? ?? 'good',
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : DateTime.now(),
      userName: userData?['name'] as String?,
      userPhotoUrl: userData?['photo_url'] as String?,
      userLevel: userData?['level'] as int?,
      userIsVerified: userData?['is_verified'] as bool?,
    );
  }

  /// Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'user_id': userId,
      'role': role,
      'is_muted': isMuted,
      'is_online': isOnline,
      'network_quality': networkQuality,
      'last_seen': lastSeen.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  LiveRoomParticipantModel copyWith({
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
    return LiveRoomParticipantModel(
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
