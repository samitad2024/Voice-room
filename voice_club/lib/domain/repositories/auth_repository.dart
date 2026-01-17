import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signup({
    required String username,
    required String email,
    required String password,
    required String fullName,
  });

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, bool>> isLoggedIn();
}
