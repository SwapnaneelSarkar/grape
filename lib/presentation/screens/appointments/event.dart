// events.dart
abstract class AppointmentEvent {}

class AddAppointmentEvent extends AppointmentEvent {
  final String doctorOrClinicName;
  final String purposeOfVisit;
  final String location;
  final DateTime appointmentDate;
  final String appointmentTime;

  AddAppointmentEvent({
    required this.doctorOrClinicName,
    required this.purposeOfVisit,
    required this.location,
    required this.appointmentDate,
    required this.appointmentTime,
  });
}
