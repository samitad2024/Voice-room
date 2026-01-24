import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/gift.dart';

/// Gift repository interface
/// Defines all gift-related operations following Clean Architecture
abstract class GiftRepository {
  /// Get all available gifts
  Future<Either<Failure, List<Gift>>> getAvailableGifts();

  /// Send a gift to a user in a room
  /// Returns the created RoomGift for animation display
  Future<Either<Failure, RoomGift>> sendGift({
    required String roomId,
    required String receiverId,
    required String giftId,
  });

  /// Get recent gifts sent in a room (for history/feed)
  Future<Either<Failure, List<RoomGift>>> getRoomGifts(String roomId);

  /// Get gifts received by a user (for profile statistics)
  Future<Either<Failure, List<RoomGift>>> getUserReceivedGifts(String userId);

  /// Get gifts sent by a user (for transaction history)
  Future<Either<Failure, List<RoomGift>>> getUserSentGifts(String userId);
}
