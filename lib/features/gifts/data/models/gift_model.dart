import '../../domain/entities/gift.dart';

/// Gift model for data layer
class GiftModel extends Gift {
  const GiftModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.coinCost,
    super.category,
    super.animationType,
    super.minLevel,
    super.isActive,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      coinCost: json['coin_cost'] as int,
      category: json['category'] as String? ?? 'basic',
      animationType: json['animation_type'] as String? ?? 'simple',
      minLevel: json['min_level'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'coin_cost': coinCost,
      'category': category,
      'animation_type': animationType,
      'min_level': minLevel,
      'is_active': isActive,
    };
  }
}

/// Room Gift model for data layer
class RoomGiftModel extends RoomGift {
  const RoomGiftModel({
    required super.id,
    required super.roomId,
    required super.senderId,
    super.senderName,
    super.senderPhotoUrl,
    required super.receiverId,
    super.receiverName,
    required super.giftId,
    required super.giftName,
    required super.giftImageUrl,
    required super.coinValue,
    required super.animationType,
    required super.createdAt,
  });

  factory RoomGiftModel.fromJson(Map<String, dynamic> json) {
    // Handle nested user data from joins
    final senderData = json['sender'] as Map<String, dynamic>?;
    final receiverData = json['receiver'] as Map<String, dynamic>?;
    final giftData = json['gift'] as Map<String, dynamic>?;

    return RoomGiftModel(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: senderData?['name'] as String?,
      senderPhotoUrl: senderData?['photo_url'] as String?,
      receiverId: json['receiver_id'] as String,
      receiverName: receiverData?['name'] as String?,
      giftId: json['gift_id'] as String,
      giftName: giftData?['name'] as String? ?? json['gift_id'] as String,
      giftImageUrl: giftData?['image_url'] as String? ?? '',
      coinValue:
          json['coin_value'] as int? ?? giftData?['coin_cost'] as int? ?? 0,
      animationType: giftData?['animation_type'] as String? ?? 'simple',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'gift_id': giftId,
      'coin_value': coinValue,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
