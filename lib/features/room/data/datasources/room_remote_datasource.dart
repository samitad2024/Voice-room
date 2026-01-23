import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
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

      final response =
          await supabase.from('rooms').insert(roomData).select().single();

      final room = RoomModel.fromJson(response);

      // Automatically join as owner
      await supabase.from('room_participants').insert({
        'room_id': room.id,
        'user_id': ownerId,
        'role': 'owner',
      });

      // Add to live participants (upsert to avoid duplicates)
      await supabase.from('live_room_participants').upsert({
        'room_id': room.id,
        'user_id': ownerId,
        'role': 'owner',
        'is_muted': false,
        'is_online': true,
        'network_quality': 'good',
      });

      return room;
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
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
      // Add to room_participants (historical record)
      final participantResponse = await supabase
          .from('room_participants')
          .insert({
            'room_id': roomId,
            'user_id': userId,
            'role': 'audience',
          })
          .select()
          .single();

      // Add to live_room_participants (realtime state, upsert to avoid duplicates)
      await supabase.from('live_room_participants').upsert({
        'room_id': roomId,
        'user_id': userId,
        'role': 'audience',
        'is_muted': false,
        'is_online': true,
        'network_quality': 'good',
      });

      // Increment total_listeners count
      await supabase.rpc('increment_room_listeners', params: {
        'room_id': roomId,
      });

      return participantResponse;
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
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
}
