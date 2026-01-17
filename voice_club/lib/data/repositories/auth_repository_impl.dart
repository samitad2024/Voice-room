import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/mock_firebase_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final MockFirebaseService firebaseService;

  AuthRepositoryImpl(this.firebaseService);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  }) async {
    try {
      final user = await firebaseService.login(username, password);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signup({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final user = await firebaseService.signup(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = firebaseService.getCurrentUser();
      if (user == null) {
        return const Left(AuthFailure('No user logged in'));
      }
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await firebaseService.logout();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final user = firebaseService.getCurrentUser();
      return Right(user != null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
