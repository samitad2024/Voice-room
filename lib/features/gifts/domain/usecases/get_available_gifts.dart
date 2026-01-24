import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/gift.dart';
import '../repositories/gift_repository.dart';

/// Get all available gifts that can be sent
class GetAvailableGifts implements UseCase<List<Gift>, NoParams> {
  final GiftRepository repository;

  GetAvailableGifts(this.repository);

  @override
  Future<Either<Failure, List<Gift>>> call(NoParams params) async {
    return await repository.getAvailableGifts();
  }
}
