import 'package:equatable/equatable.dart';

/// Room participant entity
/// Represents a user participating in a voice room
class RoomParticipant extends Equatable {
  final String id;
  final String roomId;
  final String userId;
  final String role; // 'owner', 'admin', 'speaker', 'audience'
  final DateTime joinedAt;
  final DateTime? leftAt;
  final int totalTimeSeconds;

  // User info (joined from users table)
  final String? userName;
  final String? userPhotoUrl;
  final int? userLevel;
  final bool? userIsVerified;

  const RoomParticipant({
    required this.id,
    required this.roomId,
    required this.userId,
    this.role = 'audience',
    required this.joinedAt,
    this.leftAt,
    this.totalTimeSeconds = 0,
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

  @override
  List<Object?> get props => [
        id,
        roomId,
        userId,
        role,
        joinedAt,
        leftAt,
        totalTimeSeconds,
        userName,
        userPhotoUrl,
        userLevel,
        userIsVerified,
      ];
}
