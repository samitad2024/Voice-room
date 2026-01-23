import 'package:equatable/equatable.dart';

class SpeakerRequest extends Equatable {
  final String id;
  final String roomId;
  final String userId;
  final String status;
  final DateTime createdAt;

  const SpeakerRequest({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, roomId, userId, status, createdAt];

  factory SpeakerRequest.fromJson(Map<String, dynamic> json) {
    return SpeakerRequest(
      id: json['id'],
      roomId: json['room_id'],
      userId: json['user_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
