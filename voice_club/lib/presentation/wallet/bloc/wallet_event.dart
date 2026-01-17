import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletEvent extends WalletEvent {
  const LoadWalletEvent();
}

class PurchaseCoinsEvent extends WalletEvent {
  final int amount;

  const PurchaseCoinsEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class UnlockVIPEvent extends WalletEvent {
  final int days;

  const UnlockVIPEvent(this.days);

  @override
  List<Object?> get props => [days];
}
