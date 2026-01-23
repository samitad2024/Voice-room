import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneCode implements UseCase<User, VerifyPhoneCodeParams> {
  final AuthRepository repository;

  VerifyPhoneCode(this.repository);

  @override
  Future<Either<Failure, User>> call(VerifyPhoneCodeParams params) async {
    return await repository.verifyPhoneCode(
      verificationId: params.verificationId,
      smsCode: params.smsCode,
    );
  }
}

class VerifyPhoneCodeParams extends Equatable {
  final String verificationId;
  final String smsCode;

  const VerifyPhoneCodeParams({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object> get props => [verificationId, smsCode];
}
