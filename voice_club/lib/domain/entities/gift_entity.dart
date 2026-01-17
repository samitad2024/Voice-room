import 'package:equatable/equatable.dart';

enum GiftType { rose, heart, star, diamond, crown, rocket, trophy, vip }

class GiftEntity extends Equatable {
  final String id;
  final String name;
  final String iconUrl;
  final int coinsCost;
  final GiftType type;
  final String? animationUrl;
  final bool isSpecial;

  const GiftEntity({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.coinsCost,
    required this.type,
    this.animationUrl,
    this.isSpecial = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    iconUrl,
    coinsCost,
    type,
    animationUrl,
    isSpecial,
  ];
}

class GiftTransactionEntity extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final GiftEntity gift;
  final DateTime timestamp;
  final String? roomId;

  const GiftTransactionEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.gift,
    required this.timestamp,
    this.roomId,
  });

  @override
  List<Object?> get props => [
    id,
    senderId,
    senderName,
    receiverId,
    receiverName,
    gift,
    timestamp,
    roomId,
  ];
}
