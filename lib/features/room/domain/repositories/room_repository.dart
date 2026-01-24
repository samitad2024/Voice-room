import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/room.dart';
import '../entities/room_participant.dart';
import '../entities/live_room_participant.dart';

/// Room repository interface
/// Following blueprint.md specifications for room features
abstract class RoomRepository {
  /// Get all live rooms with optional filters
  Future<Either<Failure, List<Room>>> getLiveRooms({
    String? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  });

  /// Get room by ID
  Future<Either<Failure, Room>> getRoomById(String roomId);

  /// Create a new room
  Future<Either<Failure, Room>> createRoom({
    required String title,
    required String ownerId,
    required String category,
    List<String> tags = const [],
    String roomType = 'public',
    int maxSpeakers = 20,
  });

  /// End a room (owner only)
  Future<Either<Failure, void>> endRoom(String roomId);

  /// Join a room as audience
  Future<Either<Failure, RoomParticipant>> joinRoom(String roomId);

  /// Leave a room
  Future<Either<Failure, void>> leaveRoom(String roomId);

  /// Get live participants in a room
  Future<Either<Failure, List<LiveRoomParticipant>>> getLiveParticipants(
    String roomId,
  );

  /// Request to speak (audience → speaker request)
  Future<Either<Failure, void>> requestToSpeak(String roomId);

  /// Get pending speaker requests for a room (owner/admin only)
  Future<Either<Failure, List<dynamic>>> getSpeakerRequests(String roomId);

  /// Approve speaker request (owner/admin only)
  Future<Either<Failure, void>> approveSpeakerRequest({
    required String requestId,
    required String roomId,
    required String userId,
  });

  /// Reject speaker request (owner/admin only)
  Future<Either<Failure, void>> rejectSpeakerRequest({
    required String requestId,
  });

  /// Update participant role (owner/admin only)
  Future<Either<Failure, void>> updateParticipantRole({
    required String roomId,
    required String userId,
    required String newRole,
  });

  /// Mute/unmute participant (owner/admin only)
  Future<Either<Failure, void>> toggleMute({
    required String roomId,
    required String userId,
    required bool mute,
  });

  /// Kick participant from room (owner/admin only)
  Future<Either<Failure, void>> kickParticipant({
    required String roomId,
    required String userId,
  });
}
