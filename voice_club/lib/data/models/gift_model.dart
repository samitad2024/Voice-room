import '../../domain/entities/gift_entity.dart';

class GiftModel extends GiftEntity {
  const GiftModel({
    required super.id,
    required super.name,
    required super.iconUrl,
    required super.coinsCost,
    required super.type,
    super.animationUrl,
    super.isSpecial,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String,
      coinsCost: json['coinsCost'] as int,
      type: _giftTypeFromString(json['type'] as String),
      animationUrl: json['animationUrl'] as String?,
      isSpecial: json['isSpecial'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'coinsCost': coinsCost,
      'type': _giftTypeToString(type),
      'animationUrl': animationUrl,
      'isSpecial': isSpecial,
    };
  }

  GiftEntity toEntity() => this;

  static GiftType _giftTypeFromString(String type) {
    switch (type) {
      case 'rose':
        return GiftType.rose;
      case 'heart':
        return GiftType.heart;
      case 'star':
        return GiftType.star;
      case 'diamond':
        return GiftType.diamond;
      case 'crown':
        return GiftType.crown;
      case 'rocket':
        return GiftType.rocket;
      case 'trophy':
        return GiftType.trophy;
      case 'vip':
        return GiftType.vip;
      default:
        return GiftType.rose;
    }
  }

  static String _giftTypeToString(GiftType type) {
    switch (type) {
      case GiftType.rose:
        return 'rose';
      case GiftType.heart:
        return 'heart';
      case GiftType.star:
        return 'star';
      case GiftType.diamond:
        return 'diamond';
      case GiftType.crown:
        return 'crown';
      case GiftType.rocket:
        return 'rocket';
      case GiftType.trophy:
        return 'trophy';
      case GiftType.vip:
        return 'vip';
    }
  }
}

class GiftTransactionModel extends GiftTransactionEntity {
  const GiftTransactionModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.receiverId,
    required super.receiverName,
    required super.gift,
    required super.timestamp,
    super.roomId,
  });

  factory GiftTransactionModel.fromJson(Map<String, dynamic> json) {
    return GiftTransactionModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      receiverId: json['receiverId'] as String,
      receiverName: json['receiverName'] as String,
      gift: GiftModel.fromJson(json['gift'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
      roomId: json['roomId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'gift': (gift as GiftModel).toJson(),
      'timestamp': timestamp.toIso8601String(),
      'roomId': roomId,
    };
  }

  GiftTransactionEntity toEntity() => this;
}
