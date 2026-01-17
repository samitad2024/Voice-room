import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/usecases/get_active_rooms_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetActiveRoomsUseCase getActiveRoomsUseCase;
  final RoomRepository roomRepository;

  HomeBloc({required this.getActiveRoomsUseCase, required this.roomRepository})
    : super(const HomeInitial()) {
    on<LoadActiveRoomsEvent>(_onLoadActiveRooms);
    on<LoadScheduledRoomsEvent>(_onLoadScheduledRooms);
    on<LoadTrendingRoomsEvent>(_onLoadTrendingRooms);
    on<RefreshRoomsEvent>(_onRefreshRooms);
    on<SearchRoomsEvent>(_onSearchRooms);
  }

  Future<void> _onLoadActiveRooms(
    LoadActiveRoomsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final activeResult = await getActiveRoomsUseCase();
    final scheduledResult = await roomRepository.getScheduledRooms();
    final trendingResult = await roomRepository.getTrendingRooms();

    activeResult.fold((failure) => emit(HomeError(failure.message)), (
      activeRooms,
    ) {
      scheduledResult.fold((failure) => emit(HomeError(failure.message)), (
        scheduledRooms,
      ) {
        trendingResult.fold(
          (failure) => emit(HomeError(failure.message)),
          (trendingRooms) => emit(
            HomeLoaded(
              activeRooms: activeRooms,
              scheduledRooms: scheduledRooms,
              trendingRooms: trendingRooms,
            ),
          ),
        );
      });
    });
  }

  Future<void> _onLoadScheduledRooms(
    LoadScheduledRoomsEvent event,
    Emitter<HomeState> emit,
  ) async {
    // final result = await roomRepository.getScheduledRooms();
    // Handle scheduled rooms loading
  }

  Future<void> _onLoadTrendingRooms(
    LoadTrendingRoomsEvent event,
    Emitter<HomeState> emit,
  ) async {
    // final result = await roomRepository.getTrendingRooms();
    // Handle trending rooms loading
  }

  Future<void> _onRefreshRooms(
    RefreshRoomsEvent event,
    Emitter<HomeState> emit,
  ) async {
    add(const LoadActiveRoomsEvent());
  }

  Future<void> _onSearchRooms(
    SearchRoomsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const LoadActiveRoomsEvent());
      return;
    }

    emit(const SearchLoading());

    final result = await roomRepository.searchRooms(event.query);

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (rooms) => emit(SearchLoaded(results: rooms, query: event.query)),
    );
  }
}
