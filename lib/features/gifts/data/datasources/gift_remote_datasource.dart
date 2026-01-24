import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/gift_model.dart';

/// Gift remote data source interface
abstract class GiftRemoteDataSource {
  SupabaseClient get supabase;

  /// Get all available gifts from database
  Future<List<GiftModel>> getAvailableGifts();

  /// Send a gift (creates transaction and updates balances)
  Future<RoomGiftModel> sendGift({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String giftId,
  });

  /// Get recent gifts in a room
  Future<List<RoomGiftModel>> getRoomGifts(String roomId, {int limit = 50});

  /// Get gifts received by a user
  Future<List<RoomGiftModel>> getUserReceivedGifts(String userId,
      {int limit = 100});

  /// Get gifts sent by a user
  Future<List<RoomGiftModel>> getUserSentGifts(String userId,
      {int limit = 100});
}

class GiftRemoteDataSourceImpl implements GiftRemoteDataSource {
  @override
  final SupabaseClient supabase;

  GiftRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<GiftModel>> getAvailableGifts() async {
    try {
      final response = await supabase
          .from('gifts')
          .select()
          .eq('is_active', true)
          .order('coin_cost', ascending: true);

      return (response as List)
          .map((json) => GiftModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RoomGiftModel> sendGift({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String giftId,
  }) async {
    try {
      // Call RPC function to handle gift sending with transaction
      final response = await supabase.rpc('send_gift', params: {
        'p_room_id': roomId,
        'p_sender_id': senderId,
        'p_receiver_id': receiverId,
        'p_gift_id': giftId,
      });

      if (response == null) {
        throw ServerException('Failed to send gift');
      }

      // Fetch the created gift with full details
      final giftResponse = await supabase.from('room_gifts').select('''
            *,
            sender:sender_id (name, photo_url),
            receiver:receiver_id (name),
            gift:gift_id (name, image_url, animation_type)
          ''').eq('id', response['gift_id'] as String).single();

      return RoomGiftModel.fromJson(giftResponse);
    } on PostgrestException catch (e) {
      if (e.message.contains('insufficient')) {
        throw ServerException('Insufficient coins');
      }
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<RoomGiftModel>> getRoomGifts(String roomId,
      {int limit = 50}) async {
    try {
      final response = await supabase
          .from('room_gifts')
          .select('''
            *,
            sender:sender_id (name, photo_url),
            receiver:receiver_id (name),
            gift:gift_id (name, image_url, coin_cost, animation_type)
          ''')
          .eq('room_id', roomId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => RoomGiftModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<RoomGiftModel>> getUserReceivedGifts(String userId,
      {int limit = 100}) async {
    try {
      final response = await supabase
          .from('room_gifts')
          .select('''
            *,
            sender:sender_id (name, photo_url),
            receiver:receiver_id (name),
            gift:gift_id (name, image_url, coin_cost, animation_type)
          ''')
          .eq('receiver_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => RoomGiftModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<RoomGiftModel>> getUserSentGifts(String userId,
      {int limit = 100}) async {
    try {
      final response = await supabase
          .from('room_gifts')
          .select('''
            *,
            sender:sender_id (name, photo_url),
            receiver:receiver_id (name),
            gift:gift_id (name, image_url, coin_cost, animation_type)
          ''')
          .eq('sender_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => RoomGiftModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
