import 'package:equatable/equatable.dart';
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
    emit(RoomLoading());
    final result = await getLiveRooms(GetLiveRoomsParams(
      category: event.category,
      searchQuery: event.searchQuery,
    ));
    result.fold(
      (failure) => emit(RoomError(failure.message)),
      (rooms) => emit(RoomLoaded(rooms)),
    );
  }

  Future<void> _onRefreshRoomsRequested(
    RefreshRoomsRequested event,
    Emitter<RoomState> emit,
  ) async {
    // Don't show loading for refresh
    final result = await getLiveRooms(const GetLiveRoomsParams());
    result.fold(
      (failure) => emit(RoomError(failure.message)),
      (rooms) => emit(RoomLoaded(rooms)),
    );
  }

  Future<void> _onCreateRoomRequested(
    CreateRoomRequested event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomCreating());
    final result = await createRoom(CreateRoomParams(
      title: event.title,
      ownerId: event.ownerId,
      category: event.category,
      tags: event.tags,
      roomType: event.roomType,
      maxSpeakers: event.maxSpeakers,
    ));
    result.fold(
      (failure) => emit(RoomError(failure.message)),
      (room) => emit(RoomCreated(room)),
    );
  }

  Future<void> _onJoinRoomRequested(
    JoinRoomRequested event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomJoining());
    final result = await joinRoom(JoinRoomParams(roomId: event.roomId));
    result.fold(
      (failure) => emit(RoomError(failure.message)),
      (participant) => emit(RoomJoined(participant.roomId)),
    );
  }
}
