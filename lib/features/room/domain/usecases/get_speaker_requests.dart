import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/room_repository.dart';

/// Use Case: Get Pending Speaker Requests
/// Retrieves all pending speaker requests for a room
class GetSpeakerRequests
    implements UseCase<List<dynamic>, GetSpeakerRequestsParams> {
  final RoomRepository repository;

  GetSpeakerRequests(this.repository);

  @override
  Future<Either<Failure, List<dynamic>>> call(
      GetSpeakerRequestsParams params) async {
    return await repository.getSpeakerRequests(params.roomId);
  }
}

class GetSpeakerRequestsParams {
  final String roomId;

  GetSpeakerRequestsParams({required this.roomId});
}
