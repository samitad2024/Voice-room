import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmail implements UseCase<User, LoginWithEmailParams> {
  final AuthRepository repository;

  LoginWithEmail(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginWithEmailParams params) async {
    return await repository.loginWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginWithEmailParams extends Equatable {
  final String email;
  final String password;

  const LoginWithEmailParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
