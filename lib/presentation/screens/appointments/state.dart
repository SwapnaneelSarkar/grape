// states.dart
abstract class AppointmentState {}

class AppointmentInitialState extends AppointmentState {}

class AppointmentLoadingState extends AppointmentState {}

class AppointmentScheduledState extends AppointmentState {}

class AppointmentErrorState extends AppointmentState {
  final String error;

  AppointmentErrorState({required this.error});
}
