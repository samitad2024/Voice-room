import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/room_repository.dart';

/// Use Case: Approve Speaker Request
/// Allows owner/admin to approve a speaker request
class ApproveSpeakerRequest
    implements UseCase<void, ApproveSpeakerRequestParams> {
  final RoomRepository repository;

  ApproveSpeakerRequest(this.repository);

  @override
  Future<Either<Failure, void>> call(ApproveSpeakerRequestParams params) async {
    return await repository.approveSpeakerRequest(
      requestId: params.requestId,
      roomId: params.roomId,
      userId: params.userId,
    );
  }
}

class ApproveSpeakerRequestParams {
  final String requestId;
  final String roomId;
  final String userId;

  ApproveSpeakerRequestParams({
    required this.requestId,
    required this.roomId,
    required this.userId,
  });
}
