import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/gift.dart';
import '../../domain/repositories/gift_repository.dart';
import '../datasources/gift_remote_datasource.dart';

class GiftRepositoryImpl implements GiftRepository {
  final GiftRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  GiftRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Gift>>> getAvailableGifts() async {
    if (await networkInfo.isConnected) {
      try {
        final gifts = await remoteDataSource.getAvailableGifts();
        return Right(gifts);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, RoomGift>> sendGift({
    required String roomId,
    required String receiverId,
    required String giftId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Get current user ID from Supabase auth
        final currentUser = remoteDataSource.supabase.auth.currentUser;
        if (currentUser == null) {
          return const Left(AuthFailure('Not authenticated'));
        }

        final roomGift = await remoteDataSource.sendGift(
          roomId: roomId,
          senderId: currentUser.id,
          receiverId: receiverId,
          giftId: giftId,
        );
        return Right(roomGift);
      } on ServerException catch (e) {
        if (e.message.contains('insufficient')) {
          return Left(ServerFailure('Insufficient coins'));
        }
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<RoomGift>>> getRoomGifts(String roomId) async {
    if (await networkInfo.isConnected) {
      try {
        final gifts = await remoteDataSource.getRoomGifts(roomId);
        return Right(gifts);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<RoomGift>>> getUserReceivedGifts(
      String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final gifts = await remoteDataSource.getUserReceivedGifts(userId);
        return Right(gifts);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<RoomGift>>> getUserSentGifts(
      String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final gifts = await remoteDataSource.getUserSentGifts(userId);
        return Right(gifts);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
