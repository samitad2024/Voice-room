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
}
