import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/room_repository.dart';

/// Use Case: Reject Speaker Request
/// Allows owner/admin to reject a speaker request
class RejectSpeakerRequest
    implements UseCase<void, RejectSpeakerRequestParams> {
  final RoomRepository repository;

  RejectSpeakerRequest(this.repository);

  @override
  Future<Either<Failure, void>> call(RejectSpeakerRequestParams params) async {
    return await repository.rejectSpeakerRequest(
      requestId: params.requestId,
    );
  }
}

class RejectSpeakerRequestParams {
  final String requestId;

  RejectSpeakerRequestParams({required this.requestId});
}
