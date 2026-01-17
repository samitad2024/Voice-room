import 'package:equatable/equatable.dart';
import 'user_entity.dart';

enum RoomStatus { active, scheduled, ended }

enum RoomRole { owner, superAdmin, admin, speaker, listener }

class RoomParticipant {
  final UserEntity user;
  final RoomRole role;
  final bool isMuted;
  final bool isHandRaised;
  final DateTime joinedAt;

  const RoomParticipant({
    required this.user,
    required this.role,
    this.isMuted = false,
    this.isHandRaised = false,
    required this.joinedAt,
  });
}

class RoomEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String category;
  final RoomStatus status;
  final UserEntity host;
  final List<RoomParticipant> participants;
  final List<String> bannedUserIds;
  final List<String> mutedUserIds;
  final int participantCount;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final DateTime? endedAt;
  final List<String> tags;
  final bool isPrivate;
  final String? password;
  final int maxParticipants;

  const RoomEntity({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.status,
    required this.host,
    required this.participants,
    this.bannedUserIds = const [],
    this.mutedUserIds = const [],
    required this.participantCount,
    required this.createdAt,
    this.scheduledFor,
    this.endedAt,
    this.tags = const [],
    this.isPrivate = false,
    this.password,
    this.maxParticipants = 100,
  });

  // Backward compatibility getters
  List<UserEntity> get speakers {
    return participants
        .where(
          (p) =>
              p.role == RoomRole.speaker ||
              p.role == RoomRole.owner ||
              p.role == RoomRole.superAdmin ||
              p.role == RoomRole.admin,
        )
        .map((p) => p.user)
        .toList();
  }

  List<UserEntity> get listeners {
    return participants
        .where((p) => p.role == RoomRole.listener)
        .map((p) => p.user)
        .toList();
  }

  bool get isActive => status == RoomStatus.active;
  bool get isScheduled => status == RoomStatus.scheduled;
  bool get isEnded => status == RoomStatus.ended;

  List<RoomParticipant> get admins {
    return participants
        .where((p) => p.role == RoomRole.admin || p.role == RoomRole.superAdmin)
        .toList();
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    status,
    host,
    participants,
    bannedUserIds,
    mutedUserIds,
    participantCount,
    createdAt,
    scheduledFor,
    endedAt,
    tags,
    isPrivate,
    password,
    maxParticipants,
  ];
}
