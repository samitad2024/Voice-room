import 'package:dartz/dartz.dart';
import '../../domain/entities/gift_entity.dart';
import '../../core/error/failures.dart';

abstract class GiftRepository {
  Future<Either<Failure, List<GiftEntity>>> getAvailableGifts();
  Future<Either<Failure, GiftTransactionEntity>> sendGift({
    required String receiverId,
    required String giftId,
    String? roomId,
  });
  Future<Either<Failure, List<GiftTransactionEntity>>> getGiftHistory(
    String userId,
  );
}
