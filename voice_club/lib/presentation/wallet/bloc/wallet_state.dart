import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/transaction_entity.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final UserEntity user;
  final List<TransactionEntity> transactions;

  const WalletLoaded({required this.user, required this.transactions});

  @override
  List<Object?> get props => [user, transactions];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

class CoinsPurchased extends WalletState {
  final UserEntity user;
  final int amount;

  const CoinsPurchased({required this.user, required this.amount});

  @override
  List<Object?> get props => [user, amount];
}

class VIPUnlocked extends WalletState {
  final UserEntity user;

  const VIPUnlocked(this.user);

  @override
  List<Object?> get props => [user];
}
