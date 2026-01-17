import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> getUserById(String userId);

  Future<Either<Failure, UserEntity>> getUserByUsername(String username);

  Future<Either<Failure, List<UserEntity>>> searchUsers(String query);

  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? fullName,
    String? bio,
    String? avatarUrl,
  });

  Future<Either<Failure, void>> followUser(String userId);

  Future<Either<Failure, void>> unfollowUser(String userId);

  Future<Either<Failure, List<UserEntity>>> getFollowers(String userId);

  Future<Either<Failure, List<UserEntity>>> getFollowing(String userId);
}
