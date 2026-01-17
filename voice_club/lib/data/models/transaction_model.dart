import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.amount,
    required super.balanceAfter,
    required super.timestamp,
    super.description,
    super.metadata,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: _transactionTypeFromString(json['type'] as String),
      amount: json['amount'] as int,
      balanceAfter: json['balanceAfter'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': _transactionTypeToString(type),
      'amount': amount,
      'balanceAfter': balanceAfter,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'metadata': metadata,
    };
  }

  TransactionEntity toEntity() => this;

  static TransactionType _transactionTypeFromString(String type) {
    switch (type) {
      case 'coinPurchase':
        return TransactionType.coinPurchase;
      case 'giftSent':
        return TransactionType.giftSent;
      case 'giftReceived':
        return TransactionType.giftReceived;
      case 'vipUnlock':
        return TransactionType.vipUnlock;
      case 'rewardEarned':
        return TransactionType.rewardEarned;
      case 'refund':
        return TransactionType.refund;
      default:
        return TransactionType.coinPurchase;
    }
  }

  static String _transactionTypeToString(TransactionType type) {
    switch (type) {
      case TransactionType.coinPurchase:
        return 'coinPurchase';
      case TransactionType.giftSent:
        return 'giftSent';
      case TransactionType.giftReceived:
        return 'giftReceived';
      case TransactionType.vipUnlock:
        return 'vipUnlock';
      case TransactionType.rewardEarned:
        return 'rewardEarned';
      case TransactionType.refund:
        return 'refund';
    }
  }
}
