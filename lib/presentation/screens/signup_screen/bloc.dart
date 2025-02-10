import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event.dart';
import 'state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SignupBloc() : super(SignupInitial()) {
    on<EmailChanged>((event, emit) {
      // Handle email validation logic if needed
    });

    on<UsernameChanged>((event, emit) {
      // Handle username validation logic if needed
    });

    on<PasswordChanged>((event, emit) {
      // Handle password validation logic if needed
    });

    on<NameChanged>((event, emit) {
      // Handle name validation logic if needed
    });

    on<DobChanged>((event, emit) {
      // Handle DOB validation logic if needed
    });

    on<PhoneChanged>((event, emit) {
      // Handle phone validation logic if needed
    });

    on<SignupSubmitted>((event, emit) async {
      emit(SignupLoading());
      try {
        // Create user in Firebase Authentication
        final UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: event.email,
              password: event.password,
            );

        // Save additional user details in Firestore under "users" collection,
        // including a userId field.
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'userId': userCredential.user?.uid, // Added userId field
          'name': event.name,
          'email': event.email,
          'dob': event.dob,
          'phone': event.phone,
          'username': event.username,
          'createdAt': FieldValue.serverTimestamp(),
        });

        emit(SignupSuccess());
      } catch (e) {
        emit(SignupFailure(error: e.toString()));
      }
    });
  }
}
