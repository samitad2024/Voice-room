import 'package:equatable/equatable.dart';

/// Room entity - domain model
/// Represents a voice chat room following blueprint.md specifications
class Room extends Equatable {
  final String id;
  final String title;
  final String ownerId;
  final String category;
  final List<String> tags;
  final String roomType; // 'public', 'private', 'friends_only'
  final String status; // 'live', 'ended'
  final int maxSpeakers;
  final int totalListeners;
  final DateTime createdAt;
  final DateTime? endedAt;

  const Room({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.category,
    this.tags = const [],
    this.roomType = 'public',
    this.status = 'live',
    this.maxSpeakers = 20,
    this.totalListeners = 0,
    required this.createdAt,
    this.endedAt,
  });

  bool get isLive => status == 'live';
  bool get isPublic => roomType == 'public';
  bool get isPrivate => roomType == 'private';
  bool get isFriendsOnly => roomType == 'friends_only';

  @override
  List<Object?> get props => [
        id,
        title,
        ownerId,
        category,
        tags,
        roomType,
        status,
        maxSpeakers,
        totalListeners,
        createdAt,
        endedAt,
      ];
}
