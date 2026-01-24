import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/live_room_participant.dart';
import '../models/room_model.dart';

/// Room remote data source
/// Handles all Supabase operations for rooms
abstract class RoomRemoteDataSource {
  SupabaseClient get supabase;
  Future<List<RoomModel>> getLiveRooms({
    String? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  });

  Future<RoomModel> getRoomById(String roomId);

  Future<RoomModel> createRoom({
    required String title,
    required String ownerId,
    required String category,
    List<String> tags = const [],
    String roomType = 'public',
    int maxSpeakers = 20,
  });

  Future<void> endRoom(String roomId);

  Future<Map<String, dynamic>> joinRoom({
    required String roomId,
    required String userId,
  });

  Future<void> leaveRoom({
    required String roomId,
    required String userId,
  });

  Future<List<LiveRoomParticipant>> getLiveParticipants(String roomId);

  Future<void> requestToSpeak({
    required String roomId,
    required String userId,
  });

  Future<List<dynamic>> getSpeakerRequests(String roomId);

  Future<void> approveSpeakerRequest({
    required String requestId,
    required String roomId,
    required String userId,
    required String reviewedBy,
  });

  Future<void> rejectSpeakerRequest({
    required String requestId,
    required String reviewedBy,
  });

  Future<void> updateParticipantRole({
    required String roomId,
    required String userId,
    required String newRole,
  });

  Future<void> toggleMute({
    required String roomId,
    required String userId,
    required bool mute,
  });

  Future<void> kickParticipant({
    required String roomId,
    required String userId,
  });
}

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  @override
  final SupabaseClient supabase;

  RoomRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<RoomModel>> getLiveRooms({
    String? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = supabase.from('rooms').select().eq('status', 'live');

      // Apply category filter if provided
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => RoomModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RoomModel> getRoomById(String roomId) async {
    try {
      final response =
          await supabase.from('rooms').select().eq('id', roomId).single();

      return RoomModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RoomModel> createRoom({
    required String title,
    required String ownerId,
    required String category,
    List<String> tags = const [],
    String roomType = 'public',
    int maxSpeakers = 20,
  }) async {
    try {
      debugPrint('\n   ──────────────────────────────────────────────────');
      debugPrint('   🗄️  [DATASOURCE] createRoom');
      debugPrint('   ──────────────────────────────────────────────────');
      final roomData = {
        'title': title,
        'owner_id': ownerId,
        'category': category,
        'tags': tags,
        'room_type': roomType,
        'status': 'live',
        'max_speakers': maxSpeakers,
        'total_listeners': 0,
      };

      debugPrint('   📤 Inserting room into Supabase...');
      debugPrint('      Table: rooms');
      debugPrint('      Data: $roomData');

      final response =
          await supabase.from('rooms').insert(roomData).select().single();

      final room = RoomModel.fromJson(response);
      debugPrint('   ✅ Room inserted successfully!');
      debugPrint('   🆔 Room ID: ${room.id}');

      // Automatically join as owner
      debugPrint('\n   📤 Adding owner to room_participants...');
      debugPrint('      Table: room_participants');
      debugPrint('      room_id: ${room.id}');
      debugPrint('      user_id: $ownerId');
      debugPrint('      role: owner');
      await supabase.from('room_participants').insert({
        'room_id': room.id,
        'user_id': ownerId,
        'role': 'owner',
      });
      debugPrint('   ✅ Owner added to room_participants!');

      // Add to live participants (upsert to avoid duplicates)
      debugPrint('\n   📤 Upserting owner to live_room_participants...');
      debugPrint('      Table: live_room_participants');
      await supabase.from('live_room_participants').upsert({
        'room_id': room.id,
        'user_id': ownerId,
        'role': 'owner',
        'is_muted': false,
        'is_online': true,
        'network_quality': 'good',
      });
      debugPrint('   ✅ Owner added to live_room_participants!');
      debugPrint('   ──────────────────────────────────────────────────');
      debugPrint('   ✅ [DATASOURCE] createRoom COMPLETE');
      debugPrint('   ──────────────────────────────────────────────────\n');

      return room;
    } on PostgrestException catch (e) {
      debugPrint('   ❌ [DATASOURCE] PostgrestException: ${e.message}');
      debugPrint('   ❌ Code: ${e.code}');
      debugPrint('   ❌ Details: ${e.details}');
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      debugPrint('   ❌ [DATASOURCE] Exception: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> endRoom(String roomId) async {
    try {
      // Update room status
      await supabase.from('rooms').update({
        'status': 'ended',
        'ended_at': DateTime.now().toIso8601String(),
      }).eq('id', roomId);

      // Update all participants left_at time
      await supabase
          .from('room_participants')
          .update({
            'left_at': DateTime.now().toIso8601String(),
          })
          .eq('room_id', roomId)
          .isFilter('left_at', null);

      // Clear live participants
      await supabase
          .from('live_room_participants')
          .delete()
          .eq('room_id', roomId);
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> joinRoom({
    required String roomId,
    required String userId,
  }) async {
    try {
      debugPrint('\n   ──────────────────────────────────────────────────');
      debugPrint('   🗄️  [DATASOURCE] joinRoom');
      debugPrint('   ──────────────────────────────────────────────────');
      debugPrint('   🆔 Room ID: $roomId');
      debugPrint('   👤 User ID: $userId');

      // Add to room_participants (historical record)
      debugPrint('\n   📤 Inserting into room_participants...');
      debugPrint('      Table: room_participants');
      debugPrint('      role: audience');
      final participantResponse = await supabase
          .from('room_participants')
          .insert({
            'room_id': roomId,
            'user_id': userId,
            'role': 'audience',
          })
          .select()
          .single();
      debugPrint('   ✅ Added to room_participants!');

      // Add to live_room_participants (realtime state, upsert to avoid duplicates)
      debugPrint('\n   📤 Upserting into live_room_participants...');
      debugPrint('      Table: live_room_participants');
      await supabase.from('live_room_participants').upsert({
        'room_id': roomId,
        'user_id': userId,
        'role': 'audience',
        'is_muted': false,
        'is_online': true,
        'network_quality': 'good',
      });
      debugPrint('   ✅ Added to live_room_participants!');

      // Increment total_listeners count
      debugPrint('\n   📤 Calling RPC: increment_room_listeners...');
      debugPrint('      room_id: $roomId');
      await supabase.rpc('increment_room_listeners', params: {
        'room_id': roomId,
      });
      debugPrint('   ✅ Listener count incremented!');
      debugPrint('   ──────────────────────────────────────────────────');
      debugPrint('   ✅ [DATASOURCE] joinRoom COMPLETE');
      debugPrint('   ──────────────────────────────────────────────────\n');

      return participantResponse;
    } on PostgrestException catch (e) {
      debugPrint('   ❌ [DATASOURCE] PostgrestException: ${e.message}');
      debugPrint('   ❌ Code: ${e.code}');
      debugPrint('   ❌ Details: ${e.details}');
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      debugPrint('   ❌ [DATASOURCE] Exception: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> leaveRoom({
    required String roomId,
    required String userId,
  }) async {
    try {
      // Update room_participants left_at time
      await supabase
          .from('room_participants')
          .update({
            'left_at': DateTime.now().toIso8601String(),
          })
          .eq('room_id', roomId)
          .eq('user_id', userId);

      // Remove from live participants
      await supabase
          .from('live_room_participants')
          .delete()
          .eq('room_id', roomId)
          .eq('user_id', userId);

      // Decrement total_listeners count
      await supabase.rpc('decrement_room_listeners', params: {
        'room_id': roomId,
      });
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<LiveRoomParticipant>> getLiveParticipants(String roomId) async {
    try {
      final response = await supabase
          .from('live_room_participants')
          .select()
          .eq('room_id', roomId);

      return (response as List)
          .map((json) =>
              LiveRoomParticipant.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> requestToSpeak({
    required String roomId,
    required String userId,
  }) async {
    try {
      debugPrint('\n   📤 Requesting to speak...');
      debugPrint('      room_id: $roomId');
      debugPrint('      user_id: $userId');

      // Check if user already has a pending request
      final existing = await supabase
          .from('speaker_requests')
          .select()
          .eq('room_id', roomId)
          .eq('user_id', userId)
          .eq('status', 'pending');

      if (existing.isNotEmpty) {
        throw ServerException('You already have a pending request');
      }

      // Insert new speaker request
      await supabase.from('speaker_requests').insert({
        'room_id': roomId,
        'user_id': userId,
        'status': 'pending',
      });

      debugPrint('   ✅ Speaker request created successfully!');
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<dynamic>> getSpeakerRequests(String roomId) async {
    try {
      final response = await supabase
          .from('speaker_requests')
          .select()
          .eq('room_id', roomId)
          .eq('status', 'pending')
          .order('created_at', ascending: true);

      return response as List;
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> approveSpeakerRequest({
    required String requestId,
    required String roomId,
    required String userId,
    required String reviewedBy,
  }) async {
    try {
      debugPrint('\n   ✅ Approving speaker request...');
      debugPrint('      request_id: $requestId');
      debugPrint('      user_id: $userId');

      // Update speaker request status
      await supabase.from('speaker_requests').update({
        'status': 'approved',
        'reviewed_at': DateTime.now().toIso8601String(),
        'reviewed_by': reviewedBy,
      }).eq('id', requestId);

      // Update live_room_participants role
      await supabase
          .from('live_room_participants')
          .update({
            'role': 'speaker',
          })
          .eq('room_id', roomId)
          .eq('user_id', userId);

      // Update room_participants role
      await supabase
          .from('room_participants')
          .update({
            'role': 'speaker',
          })
          .eq('room_id', roomId)
          .eq('user_id', userId)
          .isFilter('left_at', null);

      debugPrint('   ✅ Speaker request approved!');
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> rejectSpeakerRequest({
    required String requestId,
    required String reviewedBy,
  }) async {
    try {
      await supabase.from('speaker_requests').update({
        'status': 'rejected',
        'reviewed_at': DateTime.now().toIso8601String(),
        'reviewed_by': reviewedBy,
      }).eq('id', requestId);

      debugPrint('   ✅ Speaker request rejected');
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateParticipantRole({
    required String roomId,
    required String userId,
    required String newRole,
  }) async {
    try {
      // Update live_room_participants
      await supabase
          .from('live_room_participants')
          .update({
            'role': newRole,
          })
          .eq('room_id', roomId)
          .eq('user_id', userId);

      // Update room_participants
      await supabase
          .from('room_participants')
          .update({
            'role': newRole,
          })
          .eq('room_id', roomId)
          .eq('user_id', userId)
          .isFilter('left_at', null);

      debugPrint('   ✅ Participant role updated to $newRole');
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> toggleMute({
    required String roomId,
    required String userId,
    required bool mute,
  }) async {
    try {
      await supabase
          .from('live_room_participants')
          .update({
            'is_muted': mute,
          })
          .eq('room_id', roomId)
          .eq('user_id', userId);

      debugPrint('   ✅ Participant ${mute ? "muted" : "unmuted"}');
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> kickParticipant({
    required String roomId,
    required String userId,
  }) async {
    try {
      // Remove from live participants
      await supabase
          .from('live_room_participants')
          .delete()
          .eq('room_id', roomId)
          .eq('user_id', userId);

      // Update room_participants left_at time
      await supabase
          .from('room_participants')
          .update({
            'left_at': DateTime.now().toIso8601String(),
          })
          .eq('room_id', roomId)
          .eq('user_id', userId)
          .isFilter('left_at', null);

      // Decrement listener count
      await supabase.rpc('decrement_room_listeners', params: {
        'room_id': roomId,
      });

      debugPrint('   ✅ Participant kicked from room');
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
