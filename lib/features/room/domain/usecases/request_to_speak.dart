import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/room_repository.dart';

/// Use Case: Request to Speak
/// Allows audience members to request speaker role
class RequestToSpeak implements UseCase<void, RequestToSpeakParams> {
  final RoomRepository repository;

  RequestToSpeak(this.repository);

  @override
  Future<Either<Failure, void>> call(RequestToSpeakParams params) async {
    return await repository.requestToSpeak(params.roomId);
  }
}

class RequestToSpeakParams {
  final String roomId;

  RequestToSpeakParams({required this.roomId});
}
