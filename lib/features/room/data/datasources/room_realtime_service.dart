import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/live_room_participant_model.dart';
import '../../domain/entities/live_room_participant.dart';

/// Room Realtime Service
/// Manages Supabase Realtime subscriptions for live room participants
/// Following blueprint.md specifications for real-time data strategy
class RoomRealtimeService {
  final SupabaseClient supabase;

  RealtimeChannel? _participantsChannel;
  RealtimeChannel? _speakerRequestsChannel;
  final _participantsController =
      StreamController<List<LiveRoomParticipant>>.broadcast();
  final _speakerRequestsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  String? _currentRoomId;
  List<LiveRoomParticipantModel> _participants = [];
  List<Map<String, dynamic>> _speakerRequests = [];

  RoomRealtimeService({required this.supabase});

  /// Stream of live participants for the current room
  Stream<List<LiveRoomParticipant>> get participantsStream =>
      _participantsController.stream;

  /// Stream of pending speaker requests for the current room
  Stream<List<Map<String, dynamic>>> get speakerRequestsStream =>
      _speakerRequestsController.stream;

  /// Get current participants list
  List<LiveRoomParticipant> get participants =>
      List.unmodifiable(_participants);

  /// Get current speaker requests
  List<Map<String, dynamic>> get speakerRequests =>
      List.unmodifiable(_speakerRequests);

  /// Get speakers (owner, admin, speaker roles)
  List<LiveRoomParticipant> get speakers =>
      _participants.where((p) => p.canSpeak).toList();

  /// Get audience (audience role only)
  List<LiveRoomParticipant> get audience =>
      _participants.where((p) => p.isAudience).toList();

  /// Subscribe to a room's live participants
  Future<void> subscribeToRoom(String roomId) async {
    debugPrint(
        '\n╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 📡 SUBSCRIBING TO ROOM REALTIME');
    debugPrint(
        '╠══════════════════════════════════════════════════════════════');
    debugPrint('║ Room ID: $roomId');
    debugPrint(
        '╚══════════════════════════════════════════════════════════════');

    // Unsubscribe from previous room if any
    if (_currentRoomId != null && _currentRoomId != roomId) {
      await unsubscribe();
    }

    _currentRoomId = roomId;

    try {
      // First, fetch current participants
      debugPrint('   📥 Fetching initial participants...');
      await _fetchParticipants(roomId);
      debugPrint('   ✅ Found ${_participants.length} participants');

      // Subscribe to realtime changes
      debugPrint('   📡 Setting up Realtime subscription...');
      _participantsChannel = supabase
          .channel('live_room_participants:$roomId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'live_room_participants',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'room_id',
              value: roomId,
            ),
            callback: (payload) {
              debugPrint('\n   🔔 REALTIME EVENT: ${payload.eventType}');
              debugPrint('   Old: ${payload.oldRecord}');
              debugPrint('   New: ${payload.newRecord}');
              _handleRealtimeChange(payload);
            },
          )
          .subscribe((status, error) {
        debugPrint('   📡 Subscription status: $status');
        if (error != null) {
          debugPrint('   ❌ Subscription error: $error');
        }
      });

      debugPrint('   ✅ Realtime subscription active!');

      // Subscribe to speaker requests for owners/admins
      debugPrint('   📡 Setting up Speaker Requests subscription...');
      await _subscribeToSpeakerRequests(roomId);
      debugPrint('   ✅ Speaker Requests subscription active!');
    } catch (e) {
      debugPrint('   ❌ Failed to subscribe: $e');
      throw ServerException('Failed to subscribe to room: $e');
    }
  }

  /// Subscribe to speaker requests for the room
  Future<void> _subscribeToSpeakerRequests(String roomId) async {
    try {
      // Fetch initial pending requests
      final response = await supabase
          .from('speaker_requests')
          .select('''
            *,
            users:user_id (
              name,
              photo_url,
              level,
              is_verified
            )
          ''')
          .eq('room_id', roomId)
          .eq('status', 'pending')
          .order('created_at', ascending: true);

      _speakerRequests = (response as List)
          .map((json) => json as Map<String, dynamic>)
          .toList();

      _speakerRequestsController.add(_speakerRequests);
      debugPrint('   ✅ Found ${_speakerRequests.length} pending requests');

      // Subscribe to realtime changes
      _speakerRequestsChannel = supabase
          .channel('speaker_requests:$roomId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'speaker_requests',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'room_id',
              value: roomId,
            ),
            callback: (payload) {
              debugPrint('   🔔 SPEAKER REQUEST EVENT: ${payload.eventType}');
              _handleSpeakerRequestChange(payload);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('   ❌ Failed to subscribe to speaker requests: $e');
      // Non-critical, continue without speaker requests subscription
    }
  }

  /// Handle speaker request realtime changes
  void _handleSpeakerRequestChange(PostgresChangePayload payload) {
    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
        final newRequest = payload.newRecord;
        if (newRequest['status'] == 'pending') {
          _speakerRequests.add(newRequest);
          _speakerRequestsController.add(_speakerRequests);
          debugPrint('   ➕ New speaker request added');
        }
        break;
      case PostgresChangeEvent.update:
        final updatedRequest = payload.newRecord;
        final index =
            _speakerRequests.indexWhere((r) => r['id'] == updatedRequest['id']);
        if (index != -1) {
          // Remove if no longer pending
          if (updatedRequest['status'] != 'pending') {
            _speakerRequests.removeAt(index);
            debugPrint(
                '   ✅ Speaker request resolved: ${updatedRequest['status']}');
          } else {
            _speakerRequests[index] = updatedRequest;
          }
          _speakerRequestsController.add(_speakerRequests);
        }
        break;
      case PostgresChangeEvent.delete:
        final deletedRequest = payload.oldRecord;
        _speakerRequests.removeWhere((r) => r['id'] == deletedRequest['id']);
        _speakerRequestsController.add(_speakerRequests);
        debugPrint('   ➖ Speaker request deleted');
        break;
      default:
        break;
    }
  }

  /// Fetch current participants from database
  Future<void> _fetchParticipants(String roomId) async {
    try {
      // Join with users table to get user info
      final response = await supabase.from('live_room_participants').select('''
            *,
            users:user_id (
              name,
              photo_url,
              level,
              is_verified
            )
          ''').eq('room_id', roomId).eq('is_online', true);

      _participants = (response as List)
          .map((json) =>
              LiveRoomParticipantModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sort: owner first, then admins, then speakers, then audience
      _participants.sort((a, b) {
        const roleOrder = {'owner': 0, 'admin': 1, 'speaker': 2, 'audience': 3};
        return (roleOrder[a.role] ?? 4).compareTo(roleOrder[b.role] ?? 4);
      });

      _participantsController.add(_participants);
    } catch (e) {
      debugPrint('   ❌ Error fetching participants: $e');
      throw ServerException('Failed to fetch participants: $e');
    }
  }

  /// Handle realtime changes
  void _handleRealtimeChange(PostgresChangePayload payload) {
    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
        _handleInsert(payload.newRecord);
        break;
      case PostgresChangeEvent.update:
        _handleUpdate(payload.newRecord);
        break;
      case PostgresChangeEvent.delete:
        _handleDelete(payload.oldRecord);
        break;
      default:
        break;
    }
  }

  void _handleInsert(Map<String, dynamic> record) {
    debugPrint('   ➕ New participant joined: ${record['user_id']}');

    final participant = LiveRoomParticipantModel.fromJson(record);

    // Check if already exists (shouldn't happen but safety check)
    final existingIndex =
        _participants.indexWhere((p) => p.userId == participant.userId);
    if (existingIndex == -1) {
      _participants.add(participant);
      _sortAndEmit();
    }
  }

  void _handleUpdate(Map<String, dynamic> record) {
    debugPrint('   🔄 Participant updated: ${record['user_id']}');

    final participant = LiveRoomParticipantModel.fromJson(record);

    final existingIndex =
        _participants.indexWhere((p) => p.userId == participant.userId);
    if (existingIndex != -1) {
      _participants[existingIndex] = participant;
      _sortAndEmit();
    }
  }

  void _handleDelete(Map<String, dynamic> record) {
    debugPrint('   ➖ Participant left: ${record['user_id']}');

    _participants.removeWhere((p) => p.userId == record['user_id']);
    _sortAndEmit();
  }

  void _sortAndEmit() {
    // Sort: owner first, then admins, then speakers, then audience
    _participants.sort((a, b) {
      const roleOrder = {'owner': 0, 'admin': 1, 'speaker': 2, 'audience': 3};
      return (roleOrder[a.role] ?? 4).compareTo(roleOrder[b.role] ?? 4);
    });

    _participantsController.add(_participants);
  }

  /// Update participant's mute status
  Future<void> updateMuteStatus(
      String roomId, String userId, bool isMuted) async {
    debugPrint('   🎤 Updating mute status: userId=$userId, muted=$isMuted');
    try {
      await supabase
          .from('live_room_participants')
          .update({
            'is_muted': isMuted,
            'last_seen': DateTime.now().toIso8601String()
          })
          .eq('room_id', roomId)
          .eq('user_id', userId);
      debugPrint('   ✅ Mute status updated');
    } catch (e) {
      debugPrint('   ❌ Failed to update mute status: $e');
      throw ServerException('Failed to update mute status: $e');
    }
  }

  /// Update participant's network quality
  Future<void> updateNetworkQuality(
      String roomId, String userId, String quality) async {
    try {
      await supabase
          .from('live_room_participants')
          .update({
            'network_quality': quality,
            'last_seen': DateTime.now().toIso8601String()
          })
          .eq('room_id', roomId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('   ❌ Failed to update network quality: $e');
    }
  }

  /// Update participant's role
  Future<void> updateRole(String roomId, String userId, String newRole) async {
    debugPrint('   👤 Updating role: userId=$userId, newRole=$newRole');
    try {
      await supabase
          .from('live_room_participants')
          .update(
              {'role': newRole, 'last_seen': DateTime.now().toIso8601String()})
          .eq('room_id', roomId)
          .eq('user_id', userId);

      // Also update historical record
      await supabase
          .from('room_participants')
          .update({'role': newRole})
          .eq('room_id', roomId)
          .eq('user_id', userId);

      debugPrint('   ✅ Role updated');
    } catch (e) {
      debugPrint('   ❌ Failed to update role: $e');
      throw ServerException('Failed to update role: $e');
    }
  }

  /// Remove participant from room (kick)
  Future<void> removeParticipant(String roomId, String userId) async {
    debugPrint('   🚪 Removing participant: userId=$userId');
    try {
      await supabase
          .from('live_room_participants')
          .delete()
          .eq('room_id', roomId)
          .eq('user_id', userId);
      debugPrint('   ✅ Participant removed');
    } catch (e) {
      debugPrint('   ❌ Failed to remove participant: $e');
      throw ServerException('Failed to remove participant: $e');
    }
  }

  /// Update online status (for heartbeat/presence)
  Future<void> updateOnlineStatus(
      String roomId, String userId, bool isOnline) async {
    try {
      await supabase
          .from('live_room_participants')
          .update({
            'is_online': isOnline,
            'last_seen': DateTime.now().toIso8601String(),
          })
          .eq('room_id', roomId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('   ❌ Failed to update online status: $e');
    }
  }

  /// Unsubscribe from current room
  Future<void> unsubscribe() async {
    debugPrint('   📡 Unsubscribing from room realtime...');
    if (_participantsChannel != null) {
      await supabase.removeChannel(_participantsChannel!);
      _participantsChannel = null;
    }
    if (_speakerRequestsChannel != null) {
      await supabase.removeChannel(_speakerRequestsChannel!);
      _speakerRequestsChannel = null;
    }
    _currentRoomId = null;
    _participants.clear();
    _speakerRequests.clear();
    debugPrint('   ✅ Unsubscribed');
  }

  /// Dispose of the service
  void dispose() {
    unsubscribe();
    _participantsController.close();
    _speakerRequestsController.close();
  }
}
