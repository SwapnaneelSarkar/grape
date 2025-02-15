import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Events
abstract class MedicationEvent {}

class AddMedicationEvent extends MedicationEvent {
  final String medicationName;
  final int dosage;
  final String frequency;
  final String reminderTime;
  final bool repeatDaily;
  final DateTime startDate;

  AddMedicationEvent({
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.reminderTime,
    required this.repeatDaily,
    required this.startDate,
  });
}

// States
abstract class MedicationState {}

class MedicationInitialState extends MedicationState {}

class MedicationLoadingState extends MedicationState {}

class MedicationAddedState extends MedicationState {}

class MedicationErrorState extends MedicationState {
  final String error;

  MedicationErrorState({required this.error});
}

// BLoC Logic
class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MedicationBloc() : super(MedicationInitialState()) {
    // Register event handler for AddMedicationEvent
    on<AddMedicationEvent>((event, emit) async {
      try {
        emit(MedicationLoadingState());

        // Adding medication data to Firestore
        await _firestore.collection('medications').add({
          'medicationName': event.medicationName,
          'dosage': event.dosage,
          'frequency': event.frequency,
          'reminderTime': event.reminderTime,
          'repeatDaily': event.repeatDaily,
          'startDate': event.startDate,
        });

        emit(MedicationAddedState());
      } catch (e) {
        emit(MedicationErrorState(error: e.toString()));
      }
    });
  }
}
