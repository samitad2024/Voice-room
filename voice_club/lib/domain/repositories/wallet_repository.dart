import 'package:dartz/dartz.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/error/failures.dart';

abstract class WalletRepository {
  Future<Either<Failure, void>> purchaseCoins(int amount);
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
    String userId,
  );
  Future<Either<Failure, void>> unlockVIP(int days);
  Future<Either<Failure, UserEntity>> getCurrentUser();
}
