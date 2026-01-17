import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/usecases/join_room_usecase.dart';
import 'room_event.dart';
import 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final JoinRoomUseCase joinRoomUseCase;
  final RoomRepository roomRepository;

  RoomBloc({required this.joinRoomUseCase, required this.roomRepository})
    : super(const RoomInitial()) {
    on<JoinRoomEvent>(_onJoinRoom);
    on<LeaveRoomEvent>(_onLeaveRoom);
    on<ToggleMuteEvent>(_onToggleMute);
    on<RaiseHandEvent>(_onRaiseHand);
  }

  Future<void> _onJoinRoom(JoinRoomEvent event, Emitter<RoomState> emit) async {
    emit(const RoomLoading());

    final result = await joinRoomUseCase(event.roomId);

    result.fold(
      (failure) => emit(RoomError(failure.message)),
      (room) => emit(RoomJoined(room: room)),
    );
  }

  Future<void> _onLeaveRoom(
    LeaveRoomEvent event,
    Emitter<RoomState> emit,
  ) async {
    await roomRepository.leaveRoom(event.roomId);
    emit(const RoomInitial());
  }

  Future<void> _onToggleMute(
    ToggleMuteEvent event,
    Emitter<RoomState> emit,
  ) async {
    if (state is RoomJoined) {
      final currentState = state as RoomJoined;
      emit(currentState.copyWith(isMuted: !currentState.isMuted));
    }
  }

  Future<void> _onRaiseHand(
    RaiseHandEvent event,
    Emitter<RoomState> emit,
  ) async {
    if (state is RoomJoined) {
      final currentState = state as RoomJoined;
      emit(currentState.copyWith(isHandRaised: !currentState.isHandRaised));
    }
  }
}
