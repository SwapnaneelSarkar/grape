import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event.dart';
import 'state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EditProfileBloc() : super(EditProfileInitial()) {
    on<UpdateProfileSubmitted>(_onUpdateProfileSubmitted);
  }

  Future<void> _onUpdateProfileSubmitted(
    UpdateProfileSubmitted event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(EditProfileLoading());

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        emit(EditProfileFailure(error: "User not authenticated"));
        return;
      }

      // Update user data in Firestore
      await _firestore.collection('users').doc(userId).update({
        'name': event.name,
        'email': event.email,
        'phone': event.phone,
        'dob': event.dob,
        'username': event.username,
      });

      emit(EditProfileSuccess());
    } catch (e) {
      emit(EditProfileFailure(error: e.toString()));
    }
  }
}
