import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.message,
    required super.timestamp,
    super.isRead = false,
    super.imageUrl,
    super.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: _notificationTypeFromString(json['type'] as String),
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': _notificationTypeToString(type),
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'data': data,
    };
  }

  NotificationEntity toEntity() => this;

  static NotificationType _notificationTypeFromString(String type) {
    switch (type) {
      case 'giftReceived':
        return NotificationType.giftReceived;
      case 'newFollower':
        return NotificationType.newFollower;
      case 'roomInvite':
        return NotificationType.roomInvite;
      case 'levelUp':
        return NotificationType.levelUp;
      case 'vipExpiring':
        return NotificationType.vipExpiring;
      case 'moderatorAction':
        return NotificationType.moderatorAction;
      case 'announcement':
        return NotificationType.announcement;
      default:
        return NotificationType.announcement;
    }
  }

  static String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.giftReceived:
        return 'giftReceived';
      case NotificationType.newFollower:
        return 'newFollower';
      case NotificationType.roomInvite:
        return 'roomInvite';
      case NotificationType.levelUp:
        return 'levelUp';
      case NotificationType.vipExpiring:
        return 'vipExpiring';
      case NotificationType.moderatorAction:
        return 'moderatorAction';
      case NotificationType.announcement:
        return 'announcement';
    }
  }
}
