import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/gift.dart';
import '../repositories/gift_repository.dart';

/// Get recent gifts sent in a room
class GetRoomGifts implements UseCase<List<RoomGift>, GetRoomGiftsParams> {
  final GiftRepository repository;

  GetRoomGifts(this.repository);

  @override
  Future<Either<Failure, List<RoomGift>>> call(
      GetRoomGiftsParams params) async {
    return await repository.getRoomGifts(params.roomId);
  }
}

class GetRoomGiftsParams extends Equatable {
  final String roomId;

  const GetRoomGiftsParams({required this.roomId});

  @override
  List<Object> get props => [roomId];
}
