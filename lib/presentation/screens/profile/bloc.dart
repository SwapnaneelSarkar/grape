import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'event.dart';
import 'state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileBloc() : super(ProfileLoading()) {
    on<FetchProfile>((event, emit) async {
      await _mapFetchProfileToState(emit);
    });
  }

  Future<void> _mapFetchProfileToState(Emitter<ProfileState> emit) async {
    try {
      emit(ProfileLoading());

      final user = _auth.currentUser;

      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;

          emit(
            ProfileLoaded(
              name: data['name'] ?? 'No name',
              email: data['email'] ?? 'No email',
              age: data['age'] ?? 'N/A',
              gender: data['gender'] ?? 'N/A',
              phone: data['phone'] ?? 'N/A',
              // profilePic: data['profilePic'] ?? '',
            ),
          );
        } else {
          emit(ProfileFailure(error: "User data not found"));
        }
      } else {
        emit(ProfileFailure(error: "User not logged in"));
      }
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }
}
