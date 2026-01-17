import 'package:equatable/equatable.dart';
import '../../../domain/entities/room_entity.dart';

abstract class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {
  const RoomInitial();
}

class RoomLoading extends RoomState {
  const RoomLoading();
}

class RoomJoined extends RoomState {
  final RoomEntity room;
  final bool isMuted;
  final bool isHandRaised;

  const RoomJoined({
    required this.room,
    this.isMuted = true,
    this.isHandRaised = false,
  });

  @override
  List<Object?> get props => [room, isMuted, isHandRaised];

  RoomJoined copyWith({RoomEntity? room, bool? isMuted, bool? isHandRaised}) {
    return RoomJoined(
      room: room ?? this.room,
      isMuted: isMuted ?? this.isMuted,
      isHandRaised: isHandRaised ?? this.isHandRaised,
    );
  }
}

class RoomError extends RoomState {
  final String message;

  const RoomError(this.message);

  @override
  List<Object?> get props => [message];
}
