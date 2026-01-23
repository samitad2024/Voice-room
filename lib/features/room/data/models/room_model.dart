import '../../domain/entities/room.dart';

/// Room model for data layer
/// Handles JSON serialization/deserialization for Supabase
class RoomModel extends Room {
  const RoomModel({
    required super.id,
    required super.title,
    required super.ownerId,
    required super.category,
    super.tags,
    super.roomType,
    super.status,
    super.maxSpeakers,
    super.totalListeners,
    required super.createdAt,
    super.endedAt,
  });

  /// Create Room model from JSON (Supabase response)
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      title: json['title'] as String,
      ownerId: json['owner_id'] as String,
      category: json['category'] as String,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : const [],
      roomType: json['room_type'] as String? ?? 'public',
      status: json['status'] as String? ?? 'live',
      maxSpeakers: json['max_speakers'] as int? ?? 20,
      totalListeners: json['total_listeners'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
    );
  }

  /// Convert Room model to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'owner_id': ownerId,
      'category': category,
      'tags': tags,
      'room_type': roomType,
      'status': status,
      'max_speakers': maxSpeakers,
      'total_listeners': totalListeners,
      'created_at': createdAt.toIso8601String(),
      if (endedAt != null) 'ended_at': endedAt!.toIso8601String(),
    };
  }

  /// Convert to domain entity
  Room toEntity() {
    return Room(
      id: id,
      title: title,
      ownerId: ownerId,
      category: category,
      tags: tags,
      roomType: roomType,
      status: status,
      maxSpeakers: maxSpeakers,
      totalListeners: totalListeners,
      createdAt: createdAt,
      endedAt: endedAt,
    );
  }
}
