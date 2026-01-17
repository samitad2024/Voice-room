import 'package:equatable/equatable.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class JoinRoomEvent extends RoomEvent {
  final String roomId;

  const JoinRoomEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class LeaveRoomEvent extends RoomEvent {
  final String roomId;

  const LeaveRoomEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class ToggleMuteEvent extends RoomEvent {
  const ToggleMuteEvent();
}

class RaiseHandEvent extends RoomEvent {
  const RaiseHandEvent();
}
