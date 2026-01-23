import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyAge implements UseCase<User, VerifyAgeParams> {
  final AuthRepository repository;

  VerifyAge(this.repository);

  @override
  Future<Either<Failure, User>> call(VerifyAgeParams params) async {
    return await repository.verifyAge(
      uid: params.uid,
      dateOfBirth: params.dateOfBirth,
    );
  }
}

class VerifyAgeParams extends Equatable {
  final String uid;
  final DateTime dateOfBirth;

  const VerifyAgeParams({
    required this.uid,
    required this.dateOfBirth,
  });

  @override
  List<Object> get props => [uid, dateOfBirth];
}
