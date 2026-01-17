import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/room_entity.dart';

abstract class RoomRepository {
  Future<Either<Failure, List<RoomEntity>>> getActiveRooms();

  Future<Either<Failure, List<RoomEntity>>> getScheduledRooms();

  Future<Either<Failure, List<RoomEntity>>> getTrendingRooms();

  Future<Either<Failure, List<RoomEntity>>> getRoomsByCategory(String category);

  Future<Either<Failure, RoomEntity>> getRoomById(String roomId);

  Future<Either<Failure, RoomEntity>> createRoom({
    required String title,
    required String category,
    String? description,
    List<String>? tags,
  });

  Future<Either<Failure, RoomEntity>> joinRoom(String roomId);

  Future<Either<Failure, void>> leaveRoom(String roomId);

  Future<Either<Failure, List<RoomEntity>>> searchRooms(String query);
}
