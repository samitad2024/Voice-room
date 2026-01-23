import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/room_participant.dart';
import '../repositories/room_repository.dart';

/// Use case for joining a room
/// Following blueprint.md join room flow
class JoinRoom implements UseCase<RoomParticipant, JoinRoomParams> {
  final RoomRepository repository;

  JoinRoom(this.repository);

  @override
  Future<Either<Failure, RoomParticipant>> call(JoinRoomParams params) async {
    return await repository.joinRoom(params.roomId);
  }
}

class JoinRoomParams extends Equatable {
  final String roomId;

  const JoinRoomParams({required this.roomId});

  @override
  List<Object> get props => [roomId];
}
