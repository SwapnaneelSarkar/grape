import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event.dart';
import 'state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppointmentBloc() : super(AppointmentInitialState());

  @override
  Stream<AppointmentState> mapEventToState(AppointmentEvent event) async* {
    if (event is AddAppointmentEvent) {
      yield AppointmentLoadingState(); // Show loading state while adding

      try {
        // Debugging: print the event details
        print(
          "Adding Appointment Event: doctor: ${event.doctorOrClinicName}, time: ${event.appointmentTime}",
        );

        // Add the appointment to Firestore
        await _firestore.collection('appointments').add({
          'doctorOrClinicName': event.doctorOrClinicName,
          'purposeOfVisit': event.purposeOfVisit,
          'location': event.location,
          'appointmentDate': event.appointmentDate,
          'appointmentTime': event.appointmentTime,
        });

        print("Appointment added successfully!");

        // Successfully added the appointment
        yield AppointmentScheduledState();
      } catch (e) {
        // Log error
        print("Error adding appointment: $e");

        // Error occurred while adding the appointment
        yield AppointmentErrorState(error: e.toString());
      }
    }
  }
}
