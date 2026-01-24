import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/gift.dart';
import '../repositories/gift_repository.dart';

/// Send a gift to a user in a room
class SendGift implements UseCase<RoomGift, SendGiftParams> {
  final GiftRepository repository;

  SendGift(this.repository);

  @override
  Future<Either<Failure, RoomGift>> call(SendGiftParams params) async {
    return await repository.sendGift(
      roomId: params.roomId,
      receiverId: params.receiverId,
      giftId: params.giftId,
    );
  }
}

class SendGiftParams extends Equatable {
  final String roomId;
  final String receiverId;
  final String giftId;

  const SendGiftParams({
    required this.roomId,
    required this.receiverId,
    required this.giftId,
  });

  @override
  List<Object> get props => [roomId, receiverId, giftId];
}
