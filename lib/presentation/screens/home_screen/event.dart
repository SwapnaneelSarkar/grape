abstract class HomeEvent {}

class FetchUserNameEvent extends HomeEvent {
  final String userId;

  FetchUserNameEvent({required this.userId});
}
