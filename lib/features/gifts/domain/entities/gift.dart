import 'package:equatable/equatable.dart';

/// Gift entity - represents a virtual gift that can be sent in rooms
/// Following blueprint.md specifications for gifting system
class Gift extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final int coinCost;
  final String category; // 'basic', 'premium', 'exclusive'
  final String animationType; // 'simple', 'confetti', 'fullscreen'
  final int minLevel; // Minimum user level required to send (0 = all)
  final bool isActive;

  const Gift({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.coinCost,
    this.category = 'basic',
    this.animationType = 'simple',
    this.minLevel = 0,
    this.isActive = true,
  });

  bool get isBasic => category == 'basic';
  bool get isPremium => category == 'premium';
  bool get isExclusive => category == 'exclusive';
  bool get requiresLevel => minLevel > 0;

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        coinCost,
        category,
        animationType,
        minLevel,
        isActive,
      ];
}

/// Room Gift - represents a gift sent in a room (for real-time display)
class RoomGift extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final String? senderName;
  final String? senderPhotoUrl;
  final String receiverId;
  final String? receiverName;
  final String giftId;
  final String giftName;
  final String giftImageUrl;
  final int coinValue;
  final String animationType;
  final DateTime createdAt;

  const RoomGift({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.senderName,
    this.senderPhotoUrl,
    required this.receiverId,
    this.receiverName,
    required this.giftId,
    required this.giftName,
    required this.giftImageUrl,
    required this.coinValue,
    required this.animationType,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        roomId,
        senderId,
        senderName,
        senderPhotoUrl,
        receiverId,
        receiverName,
        giftId,
        giftName,
        giftImageUrl,
        coinValue,
        animationType,
        createdAt,
      ];
}
