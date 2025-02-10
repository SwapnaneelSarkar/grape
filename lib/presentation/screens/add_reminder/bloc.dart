import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'event.dart';
import 'state.dart';

class MedicineReminderBloc
    extends Bloc<MedicineReminderEvent, MedicineReminderState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MedicineReminderBloc() : super(MedicineReminderInitial()) {
    // Handle adding a new reminder
    on<MedicineReminderAdded>((event, emit) async {
      emit(MedicineReminderLoading());
      try {
        final userId = _auth.currentUser?.uid;

        if (userId != null) {
          // Add the reminder to Firestore with 'is_active' defaulting to true
          await _firestore
              .collection('meds_reminder')
              .doc(userId)
              .collection('reminders')
              .add({
                'medicineName': event.medicineName,
                'time': event.time, // Store DateTime or Timestamp directly
                'createdAt': FieldValue.serverTimestamp(),
                'is_active': true, // Default value for 'is_active' is true
              });

          emit(MedicineReminderSuccess());
        } else {
          emit(MedicineReminderFailure(error: "User not authenticated"));
        }
      } catch (e) {
        emit(MedicineReminderFailure(error: e.toString()));
      }
    });
  }
}
