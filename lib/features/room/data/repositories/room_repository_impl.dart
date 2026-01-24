import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/room_participant.dart';
import '../../domain/entities/live_room_participant.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_remote_datasource.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  RoomRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Room>>> getLiveRooms({
    String? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final rooms = await remoteDataSource.getLiveRooms(
        category: category,
        searchQuery: searchQuery,
        limit: limit,
        offset: offset,
      );
      return Right(rooms.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Room>> getRoomById(String roomId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final room = await remoteDataSource.getRoomById(roomId);
      return Right(room.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Room>> createRoom({
    required String title,
    required String ownerId,
    required String category,
    List<String> tags = const [],
    String roomType = 'public',
    int maxSpeakers = 20,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final room = await remoteDataSource.createRoom(
        title: title,
        ownerId: ownerId,
        category: category,
        tags: tags,
        roomType: roomType,
        maxSpeakers: maxSpeakers,
      );
      return Right(room.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> endRoom(String roomId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.endRoom(roomId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoomParticipant>> joinRoom(String roomId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      // Get current user ID
      final currentUser = remoteDataSource.supabase.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure('User not logged in'));
      }

      final participantData = await remoteDataSource.joinRoom(
        roomId: roomId,
        userId: currentUser.id,
      );

      // Convert to RoomParticipant entity
      final participant = RoomParticipant(
        id: participantData['id'] as String,
        roomId: participantData['room_id'] as String,
        userId: participantData['user_id'] as String,
        role: participantData['role'] as String? ?? 'audience',
        joinedAt: DateTime.parse(participantData['joined_at'] as String),
      );

      return Right(participant);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveRoom(String roomId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final currentUser = remoteDataSource.supabase.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure('User not logged in'));
      }

      await remoteDataSource.leaveRoom(
        roomId: roomId,
        userId: currentUser.id,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LiveRoomParticipant>>> getLiveParticipants(
    String roomId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final participants = await remoteDataSource.getLiveParticipants(roomId);
      return Right(participants);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestToSpeak(String roomId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final currentUser = remoteDataSource.supabase.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure('User not logged in'));
      }

      await remoteDataSource.requestToSpeak(
        roomId: roomId,
        userId: currentUser.id,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getSpeakerRequests(
      String roomId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final requests = await remoteDataSource.getSpeakerRequests(roomId);
      return Right(requests);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveSpeakerRequest({
    required String requestId,
    required String roomId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final currentUser = remoteDataSource.supabase.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure('User not logged in'));
      }

      await remoteDataSource.approveSpeakerRequest(
        requestId: requestId,
        roomId: roomId,
        userId: userId,
        reviewedBy: currentUser.id,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectSpeakerRequest({
    required String requestId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final currentUser = remoteDataSource.supabase.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure('User not logged in'));
      }

      await remoteDataSource.rejectSpeakerRequest(
        requestId: requestId,
        reviewedBy: currentUser.id,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateParticipantRole({
    required String roomId,
    required String userId,
    required String newRole,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.updateParticipantRole(
        roomId: roomId,
        userId: userId,
        newRole: newRole,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleMute({
    required String roomId,
    required String userId,
    required bool mute,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.toggleMute(
        roomId: roomId,
        userId: userId,
        mute: mute,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> kickParticipant({
    required String roomId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.kickParticipant(
        roomId: roomId,
        userId: userId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
