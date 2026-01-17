import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

class GetActiveRoomsUseCase {
  final RoomRepository repository;

  GetActiveRoomsUseCase(this.repository);

  Future<Either<Failure, List<RoomEntity>>> call() async {
    return await repository.getActiveRooms();
  }
}
