import 'package:equatable/equatable.dart';

enum NotificationType {
  giftReceived,
  newFollower,
  roomInvite,
  levelUp,
  vipExpiring,
  moderatorAction,
  announcement,
}

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final Map<String, dynamic>? data;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.data,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    message,
    timestamp,
    isRead,
    imageUrl,
    data,
  ];
}
