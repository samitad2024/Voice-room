import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/mock_firebase_service.dart';

class RoomRepositoryImpl implements RoomRepository {
  final MockFirebaseService firebaseService;

  RoomRepositoryImpl(this.firebaseService);

  @override
  Future<Either<Failure, List<RoomEntity>>> getActiveRooms() async {
    try {
      final rooms = await firebaseService.getActiveRooms();
      return Right(rooms);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RoomEntity>>> getScheduledRooms() async {
    try {
      final rooms = await firebaseService.getScheduledRooms();
      return Right(rooms);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RoomEntity>>> getTrendingRooms() async {
    try {
      final rooms = await firebaseService.getTrendingRooms();
      return Right(rooms);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RoomEntity>>> getRoomsByCategory(
    String category,
  ) async {
    try {
      final rooms = await firebaseService.getRoomsByCategory(category);
      return Right(rooms);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoomEntity>> getRoomById(String roomId) async {
    try {
      final room = await firebaseService.getRoomById(roomId);
      return Right(room);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoomEntity>> createRoom({
    required String title,
    required String category,
    String? description,
    List<String>? tags,
  }) async {
    try {
      final room = await firebaseService.createRoom(
        title: title,
        category: category,
        description: description,
        tags: tags,
      );
      return Right(room);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoomEntity>> joinRoom(String roomId) async {
    try {
      final room = await firebaseService.joinRoom(roomId);
      return Right(room);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveRoom(String roomId) async {
    try {
      await firebaseService.leaveRoom(roomId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RoomEntity>>> searchRooms(String query) async {
    try {
      final rooms = await firebaseService.searchRooms(query);
      return Right(rooms);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
