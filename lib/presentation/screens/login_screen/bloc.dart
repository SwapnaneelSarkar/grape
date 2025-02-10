import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'event.dart';
import 'state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  LoginBloc() : super(LoginInitial()) {
    on<CheckLoginStatus>((event, emit) async {
      emit(LoginLoading());
      try {
        String? token = await _secureStorage.read(key: 'authToken');
        String? userId = await _secureStorage.read(key: 'userId');

        print("🔍 Checking Secure Login Token: $token");
        print("🔍 Checking Secure User ID: $userId");

        if (token != null && userId != null) {
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(userId).get();

          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;

            emit(
              LoginSuccess(
                userId: userId,
                name: userData['name'] ?? '',
                email: userData['email'] ?? '',
              ),
            );
          } else {
            emit(
              LoginFailure(error: "User data not found. Please login again."),
            );
          }
        } else {
          emit(LoginInitial());
        }
      } catch (e) {
        emit(
          LoginFailure(error: "Error checking login status. Please try again."),
        );
      }
    });

    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        User? user = userCredential.user;
        if (user != null) {
          String? token = await user.getIdToken(true);

          if (token != null) {
            await _secureStorage.write(key: 'authToken', value: token);
            await _secureStorage.write(key: 'userId', value: user.uid);

            DocumentSnapshot userDoc =
                await _firestore.collection('users').doc(user.uid).get();

            if (userDoc.exists) {
              final userData = userDoc.data() as Map<String, dynamic>;

              emit(
                LoginSuccess(
                  userId: user.uid,
                  name: userData['name'] ?? '',
                  email: userData['email'] ?? '',
                ),
              );
            } else {
              emit(LoginFailure(error: "User data not found in Firestore."));
            }
          }
        }
      } catch (e) {
        emit(LoginFailure(error: "Login failed. Please try again."));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _auth.signOut();
      await _secureStorage.delete(key: 'authToken');
      await _secureStorage.delete(key: 'userId');

      emit(LoginInitial());
    });
  }
}
