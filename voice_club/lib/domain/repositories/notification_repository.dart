import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(
    String userId,
  );
  Future<Either<Failure, void>> markAsRead(String notificationId);
}
