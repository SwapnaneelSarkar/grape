import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'event.dart';
import 'state.dart';

class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MedicationBloc() : super(MedicationInitialState()) {
    // Register event handler for AddMedicationEvent
    on<AddMedicationEvent>((event, emit) async {
      try {
        emit(MedicationLoadingState());

        // Check if the user is authenticated
        User? user = _auth.currentUser;
        if (user == null) {
          emit(MedicationErrorState(error: 'User not authenticated'));
          print("DEBUG: User is not authenticated");
          return;
        }

        print("DEBUG: User UID: ${user.uid}");

        // Prepare medication data
        final medicationData = {
          'medicationName': event.medicationName,
          'dosage': event.dosage,
          'frequency': event.frequency,
          'reminderTime': event.reminderTime,
          'repeatDaily': event.repeatDaily,
          'startDate': event.startDate,
        };

        print("DEBUG: Medication data to save: $medicationData");

        // Adding medication data to Firestore under the user's UID
        await _firestore
            .collection('users')
            .doc(user.uid) // Store under the user's UID
            .collection('medications')
            .add(medicationData);

        print("DEBUG: Medication successfully added to Firestore");

        emit(MedicationAddedState());
      } catch (e) {
        print("DEBUG: Error occurred: $e");
        emit(MedicationErrorState(error: e.toString()));
      }
    });
  }
}
