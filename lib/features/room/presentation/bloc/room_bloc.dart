import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/room.dart';
import '../../domain/usecases/create_room.dart';
import '../../domain/usecases/get_live_rooms.dart';
import '../../domain/usecases/join_room.dart';

part 'room_event.dart';
part 'room_state.dart';

/// Room BLoC - Manages room discovery and operations
/// Following blueprint.md specifications
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final GetLiveRooms getLiveRooms;
  final CreateRoom createRoom;
  final JoinRoom joinRoom;

  RoomBloc({
    required this.getLiveRooms,
    required this.createRoom,
    required this.joinRoom,
  }) : super(RoomInitial()) {
    on<LoadLiveRoomsRequested>(_onLoadLiveRoomsRequested);
    on<RefreshRoomsRequested>(_onRefreshRoomsRequested);
    on<CreateRoomRequested>(_onCreateRoomRequested);
    on<JoinRoomRequested>(_onJoinRoomRequested);
  }

  Future<void> _onLoadLiveRoomsRequested(
    LoadLiveRoomsRequested event,
    Emitter<RoomState> emit,
  ) async {
    debugPrint(
        '\n╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🏠 LOAD LIVE ROOMS REQUESTED');
    debugPrint(
        '╚══════════════════════════════════════════════════════════════');
    debugPrint('   📊 Category: ${event.category ?? "All"}');
    debugPrint('   🔍 Search: ${event.searchQuery ?? "None"}');
    emit(RoomLoading());
    debugPrint('   ⏳ Fetching rooms from Supabase...');
    final result = await getLiveRooms(GetLiveRoomsParams(
      category: event.category,
      searchQuery: event.searchQuery,
    ));
    result.fold(
      (failure) {
        debugPrint('   ❌ Failed to load rooms: ${failure.message}');
        debugPrint('   📍 State → RoomError');
        emit(RoomError(failure.message));
      },
      (rooms) {
        debugPrint('   ✅ Loaded ${rooms.length} live rooms');
        debugPrint('   📍 State → RoomLoaded');
        emit(RoomLoaded(rooms));
      },
    );
  }

  Future<void> _onRefreshRoomsRequested(
    RefreshRoomsRequested event,
    Emitter<RoomState> emit,
  ) async {
    debugPrint(
        '\n╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🔄 REFRESH ROOMS REQUESTED');
    debugPrint(
        '╚══════════════════════════════════════════════════════════════');
    debugPrint('   ⏳ Refreshing rooms (silent)...');
    // Don't show loading for refresh
    final result = await getLiveRooms(const GetLiveRoomsParams());
    result.fold(
      (failure) {
        debugPrint('   ❌ Refresh failed: ${failure.message}');
        debugPrint('   📍 State → RoomError');
        emit(RoomError(failure.message));
      },
      (rooms) {
        debugPrint('   ✅ Refreshed - ${rooms.length} live rooms');
        debugPrint('   📍 State → RoomLoaded');
        emit(RoomLoaded(rooms));
      },
    );
  }

  Future<void> _onCreateRoomRequested(
    CreateRoomRequested event,
    Emitter<RoomState> emit,
  ) async {
    debugPrint(
        '\n╔══════════════════════════════════════════════════════════════');
    debugPrint('║ ➕ CREATE ROOM REQUESTED');
    debugPrint(
        '╚══════════════════════════════════════════════════════════════');
    debugPrint('   🏠 Title: ${event.title}');
    debugPrint('   👤 Owner ID: ${event.ownerId}');
    debugPrint('   📊 Category: ${event.category}');
    debugPrint('   🎯 Room Type: ${event.roomType}');
    debugPrint('   🔊 Max Speakers: ${event.maxSpeakers}');
    debugPrint('   🏷️ Tags: ${event.tags}');
    emit(RoomCreating());
    debugPrint('   ⏳ Creating room in Supabase...');
    final result = await createRoom(CreateRoomParams(
      title: event.title,
      ownerId: event.ownerId,
      category: event.category,
      tags: event.tags,
      roomType: event.roomType,
      maxSpeakers: event.maxSpeakers,
    ));
    result.fold(
      (failure) {
        debugPrint('   ❌ Room creation failed: ${failure.message}');
        debugPrint('   📍 State → RoomError');
        emit(RoomError(failure.message));
      },
      (room) {
        debugPrint('   ✅ Room created successfully!');
        debugPrint('   🆔 Room ID: ${room.id}');
        debugPrint('   🏠 Room Title: ${room.title}');
        debugPrint('   📍 State → RoomCreated');
        debugPrint(
            '   ➡️  Next: Navigate to InteractiveRoomPage → Token generation');
        emit(RoomCreated(room));
      },
    );
  }

  Future<void> _onJoinRoomRequested(
    JoinRoomRequested event,
    Emitter<RoomState> emit,
  ) async {
    debugPrint(
        '\n╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🚦 JOIN ROOM REQUESTED');
    debugPrint(
        '╚══════════════════════════════════════════════════════════════');
    debugPrint('   🆔 Room ID: ${event.roomId}');
    emit(RoomJoining());
    debugPrint('   ⏳ Adding user to room participants...');
    final result = await joinRoom(JoinRoomParams(roomId: event.roomId));
    result.fold(
      (failure) {
        debugPrint('   ❌ Join room failed: ${failure.message}');
        debugPrint('   📍 State → RoomError');
        emit(RoomError(failure.message));
      },
      (participant) {
        debugPrint('   ✅ Joined room successfully!');
        debugPrint('   🆔 Participant Room ID: ${participant.roomId}');
        debugPrint('   📍 State → RoomJoined');
        debugPrint(
            '   ➡️  Next: Navigate to InteractiveRoomPage → Token generation');
        emit(RoomJoined(participant.roomId));
      },
    );
  }
}
