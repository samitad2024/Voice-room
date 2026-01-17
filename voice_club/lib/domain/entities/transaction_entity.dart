import 'package:equatable/equatable.dart';

enum TransactionType {
  coinPurchase,
  giftSent,
  giftReceived,
  vipUnlock,
  rewardEarned,
  refund,
}

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final int amount;
  final int balanceAfter;
  final DateTime timestamp;
  final String? description;
  final Map<String, dynamic>? metadata;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.timestamp,
    this.description,
    this.metadata,
  });

  bool get isCredit => amount > 0;
  bool get isDebit => amount < 0;

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    amount,
    balanceAfter,
    timestamp,
    description,
    metadata,
  ];
}
