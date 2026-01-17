import '../../domain/entities/room_entity.dart';
import 'user_model.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.title,
    super.description,
    required super.category,
    required super.status,
    required super.host,
    required super.participants,
    super.bannedUserIds,
    super.mutedUserIds,
    required super.participantCount,
    required super.createdAt,
    super.scheduledFor,
    super.endedAt,
    super.tags,
    super.isPrivate,
    super.password,
    super.maxParticipants,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      status: _statusFromString(json['status'] as String),
      host: UserModel.fromJson(json['host'] as Map<String, dynamic>),
      participants: (json['participants'] as List<dynamic>)
          .map(
            (e) => RoomParticipant(
              user: UserModel.fromJson(e['user'] as Map<String, dynamic>),
              role: _roleFromString(e['role'] as String),
              isMuted: e['isMuted'] as bool? ?? false,
              isHandRaised: e['isHandRaised'] as bool? ?? false,
              joinedAt: DateTime.parse(e['joinedAt'] as String),
            ),
          )
          .toList(),
      bannedUserIds:
          (json['bannedUserIds'] as List<dynamic>?)?.cast<String>() ?? [],
      mutedUserIds:
          (json['mutedUserIds'] as List<dynamic>?)?.cast<String>() ?? [],
      participantCount: json['participantCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.parse(json['scheduledFor'] as String)
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String)
          : null,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      isPrivate: json['isPrivate'] as bool? ?? false,
      password: json['password'] as String?,
      maxParticipants: json['maxParticipants'] as int? ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': _statusToString(status),
      'host': (host as UserModel).toJson(),
      'participants': participants
          .map(
            (p) => {
              'user': (p.user as UserModel).toJson(),
              'role': _roleToString(p.role),
              'isMuted': p.isMuted,
              'isHandRaised': p.isHandRaised,
              'joinedAt': p.joinedAt.toIso8601String(),
            },
          )
          .toList(),
      'bannedUserIds': bannedUserIds,
      'mutedUserIds': mutedUserIds,
      'participantCount': participantCount,
      'createdAt': createdAt.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'tags': tags,
      'isPrivate': isPrivate,
      'password': password,
      'maxParticipants': maxParticipants,
    };
  }

  static RoomStatus _statusFromString(String status) {
    switch (status) {
      case 'active':
        return RoomStatus.active;
      case 'scheduled':
        return RoomStatus.scheduled;
      case 'ended':
        return RoomStatus.ended;
      default:
        return RoomStatus.ended;
    }
  }

  static String _statusToString(RoomStatus status) {
    switch (status) {
      case RoomStatus.active:
        return 'active';
      case RoomStatus.scheduled:
        return 'scheduled';
      case RoomStatus.ended:
        return 'ended';
    }
  }

  static RoomRole _roleFromString(String role) {
    switch (role) {
      case 'owner':
        return RoomRole.owner;
      case 'superAdmin':
        return RoomRole.superAdmin;
      case 'admin':
        return RoomRole.admin;
      case 'speaker':
        return RoomRole.speaker;
      case 'listener':
        return RoomRole.listener;
      default:
        return RoomRole.listener;
    }
  }

  static String _roleToString(RoomRole role) {
    switch (role) {
      case RoomRole.owner:
        return 'owner';
      case RoomRole.superAdmin:
        return 'superAdmin';
      case RoomRole.admin:
        return 'admin';
      case RoomRole.speaker:
        return 'speaker';
      case RoomRole.listener:
        return 'listener';
    }
  }

  RoomEntity toEntity() {
    return RoomEntity(
      id: id,
      title: title,
      description: description,
      category: category,
      status: status,
      host: host,
      participants: participants,
      bannedUserIds: bannedUserIds,
      mutedUserIds: mutedUserIds,
      participantCount: participantCount,
      createdAt: createdAt,
      scheduledFor: scheduledFor,
      endedAt: endedAt,
      tags: tags,
      isPrivate: isPrivate,
      password: password,
      maxParticipants: maxParticipants,
    );
  }
}
