import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/gift_entity.dart';
import '../../domain/repositories/gift_repository.dart';
import '../datasources/mock_firebase_service.dart';

class GiftRepositoryImpl implements GiftRepository {
  final MockFirebaseService firebaseService;

  GiftRepositoryImpl({required this.firebaseService});

  @override
  Future<Either<Failure, List<GiftEntity>>> getAvailableGifts() async {
    try {
      final gifts = await firebaseService.getAvailableGifts();
      return Right(gifts);
    } catch (e) {
      return Left(ServerFailure('Failed to perform operation'));
    }
  }

  @override
  Future<Either<Failure, GiftTransactionEntity>> sendGift({
    required String receiverId,
    required String giftId,
    String? roomId,
  }) async {
    try {
      final transaction = await firebaseService.sendGift(
        receiverId: receiverId,
        giftId: giftId,
        roomId: roomId,
      );
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure('Failed to perform operation'));
    }
  }

  @override
  Future<Either<Failure, List<GiftTransactionEntity>>> getGiftHistory(
    String userId,
  ) async {
    try {
      final history = await firebaseService.getGiftHistory(userId);
      return Right(history);
    } catch (e) {
      return Left(ServerFailure('Failed to perform operation'));
    }
  }
}
