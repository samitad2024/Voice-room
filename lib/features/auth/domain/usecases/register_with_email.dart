import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterWithEmail implements UseCase<User, RegisterWithEmailParams> {
  final AuthRepository repository;

  RegisterWithEmail(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterWithEmailParams params) async {
    return await repository.registerWithEmail(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

class RegisterWithEmailParams extends Equatable {
  final String email;
  final String password;
  final String name;

  const RegisterWithEmailParams({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}
