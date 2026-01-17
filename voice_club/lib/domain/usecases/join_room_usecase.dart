import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

class JoinRoomUseCase {
  final RoomRepository repository;

  JoinRoomUseCase(this.repository);

  Future<Either<Failure, RoomEntity>> call(String roomId) async {
    return await repository.joinRoom(roomId);
  }
}
