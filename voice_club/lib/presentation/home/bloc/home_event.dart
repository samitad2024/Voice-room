import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveRoomsEvent extends HomeEvent {
  const LoadActiveRoomsEvent();
}

class LoadScheduledRoomsEvent extends HomeEvent {
  const LoadScheduledRoomsEvent();
}

class LoadTrendingRoomsEvent extends HomeEvent {
  const LoadTrendingRoomsEvent();
}

class RefreshRoomsEvent extends HomeEvent {
  const RefreshRoomsEvent();
}

class SearchRoomsEvent extends HomeEvent {
  final String query;

  const SearchRoomsEvent(this.query);

  @override
  List<Object?> get props => [query];
}
