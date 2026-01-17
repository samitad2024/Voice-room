import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/mock_firebase_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final MockFirebaseService firebaseService;

  NotificationRepositoryImpl({required this.firebaseService});

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(
    String userId,
  ) async {
    try {
      final notifications = await firebaseService.getNotifications(userId);
      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure('Failed to perform operation'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await firebaseService.markNotificationAsRead(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to perform operation'));
    }
  }
}
