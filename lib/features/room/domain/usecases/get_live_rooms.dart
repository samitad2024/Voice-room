import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/room.dart';
import '../repositories/room_repository.dart';

/// Use case for getting live rooms
/// Supports filtering by category and search
class GetLiveRooms implements UseCase<List<Room>, GetLiveRoomsParams> {
  final RoomRepository repository;

  GetLiveRooms(this.repository);

  @override
  Future<Either<Failure, List<Room>>> call(GetLiveRoomsParams params) async {
    return await repository.getLiveRooms(
      category: params.category,
      searchQuery: params.searchQuery,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetLiveRoomsParams extends Equatable {
  final String? category;
  final String? searchQuery;
  final int limit;
  final int offset;

  const GetLiveRoomsParams({
    this.category,
    this.searchQuery,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [category, searchQuery, limit, offset];
}
