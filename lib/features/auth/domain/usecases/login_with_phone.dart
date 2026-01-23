import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LoginWithPhone implements UseCase<String, LoginWithPhoneParams> {
  final AuthRepository repository;

  LoginWithPhone(this.repository);

  @override
  Future<Either<Failure, String>> call(LoginWithPhoneParams params) async {
    return await repository.loginWithPhone(params.phoneNumber);
  }
}

class LoginWithPhoneParams extends Equatable {
  final String phoneNumber;

  const LoginWithPhoneParams({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}
