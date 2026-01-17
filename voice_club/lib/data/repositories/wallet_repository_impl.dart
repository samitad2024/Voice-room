import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/mock_firebase_service.dart';

class WalletRepositoryImpl implements WalletRepository {
  final MockFirebaseService firebaseService;

  WalletRepositoryImpl({required this.firebaseService});

  @override
  Future<Either<Failure, void>> purchaseCoins(int amount) async {
    try {
      await firebaseService.purchaseCoins(amount);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to perform operation'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
    String userId,
  ) async {
    try {
      final transactions = await firebaseService.getTransactions(userId);
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure('Failed to perform operation'));
    }
  }

  @override
  Future<Either<Failure, void>> unlockVIP(int days) async {
    try {
      await firebaseService.unlockVIP(days);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to perform operation'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = firebaseService.getCurrentUser();
      if (user == null) {
        return Left(ServerFailure('Failed to perform operation'));
      }
      return Right(user.toEntity());
    } catch (e) {
      return Left(ServerFailure('Failed to perform operation'));
    }
  }
}
