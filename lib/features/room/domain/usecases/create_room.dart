import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/room.dart';
import '../repositories/room_repository.dart';

/// Use case for creating a new room
/// Following blueprint.md room creation flow
class CreateRoom implements UseCase<Room, CreateRoomParams> {
  final RoomRepository repository;

  CreateRoom(this.repository);

  @override
  Future<Either<Failure, Room>> call(CreateRoomParams params) async {
    return await repository.createRoom(
      title: params.title,
      ownerId: params.ownerId,
      category: params.category,
      tags: params.tags,
      roomType: params.roomType,
      maxSpeakers: params.maxSpeakers,
    );
  }
}

class CreateRoomParams extends Equatable {
  final String title;
  final String ownerId;
  final String category;
  final List<String> tags;
  final String roomType;
  final int maxSpeakers;

  const CreateRoomParams({
    required this.title,
    required this.ownerId,
    required this.category,
    this.tags = const [],
    this.roomType = 'public',
    this.maxSpeakers = 20,
  });

  @override
  List<Object?> get props => [title, ownerId, category, tags, roomType, maxSpeakers];
}
