import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> loginWithPhone(String phoneNumber) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final verificationId = await remoteDataSource.loginWithPhone(phoneNumber);
      return Right(verificationId);
    } on AuthException catch (e) {
      return Left(InvalidPhoneNumberFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final userModel = await remoteDataSource.verifyPhoneCode(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(InvalidVerificationCodeFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final userModel = await remoteDataSource.loginWithGoogle();
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final userModel = await remoteDataSource.loginWithEmail(
        email: email,
        password: password,
      );
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final userModel = await remoteDataSource.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      if (e.message.contains('weak')) {
        return Left(WeakPasswordFailure(e.message));
      } else if (e.message.contains('in use')) {
        return Left(EmailAlreadyInUseFailure(e.message));
      }
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyAge({
    required String uid,
    required DateTime dateOfBirth,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final userModel = await remoteDataSource.verifyAge(
        uid: uid,
        dateOfBirth: dateOfBirth,
      );
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AgeVerificationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await remoteDataSource.isAuthenticated();
    } catch (e) {
      return false;
    }
  }
}
