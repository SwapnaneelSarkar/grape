abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String userName;

  HomeLoaded({required this.userName});
}

class HomeError extends HomeState {
  final String error;

  HomeError({required this.error});
}
