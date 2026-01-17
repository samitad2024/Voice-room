import 'package:equatable/equatable.dart';
import '../../../domain/entities/room_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<RoomEntity> activeRooms;
  final List<RoomEntity> scheduledRooms;
  final List<RoomEntity> trendingRooms;

  const HomeLoaded({
    required this.activeRooms,
    required this.scheduledRooms,
    required this.trendingRooms,
  });

  @override
  List<Object?> get props => [activeRooms, scheduledRooms, trendingRooms];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class SearchLoading extends HomeState {
  const SearchLoading();
}

class SearchLoaded extends HomeState {
  final List<RoomEntity> results;
  final String query;

  const SearchLoaded({required this.results, required this.query});

  @override
  List<Object?> get props => [results, query];
}
