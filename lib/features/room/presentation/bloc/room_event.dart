part of 'room_bloc.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class LoadLiveRoomsRequested extends RoomEvent {
  final String? category;
  final String? searchQuery;

  const LoadLiveRoomsRequested({
    this.category,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [category, searchQuery];
}

class RefreshRoomsRequested extends RoomEvent {
  const RefreshRoomsRequested();
}

class CreateRoomRequested extends RoomEvent {
  final String title;
  final String ownerId;
  final String category;
  final List<String> tags;
  final String roomType;
  final int maxSpeakers;

  const CreateRoomRequested({
    required this.title,
    required this.ownerId,
    required this.category,
    this.tags = const [],
    this.roomType = 'public',
    this.maxSpeakers = 20,
  });

  @override
  List<Object?> get props => [title, ownerId, category, tags, roomType, maxSpeakers];
}

class JoinRoomRequested extends RoomEvent {
  final String roomId;

  const JoinRoomRequested(this.roomId);

  @override
  List<Object> get props => [roomId];
}
