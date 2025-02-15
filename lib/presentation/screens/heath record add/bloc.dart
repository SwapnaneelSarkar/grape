import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'event.dart';
import 'state.dart';

class HealthRecordBloc extends Bloc<HealthRecordEvent, HealthRecordState> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HealthRecordBloc() : super(HealthRecordInitial());

  @override
  Stream<HealthRecordState> mapEventToState(HealthRecordEvent event) async* {
    if (event is UploadFileEvent) {
      yield UploadingState();
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        TaskSnapshot snapshot = await _storage
            .ref('uploads/$fileName.${event.fileType}')
            .putFile(event.file);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        yield UploadedState(downloadUrl);
      } catch (e) {
        yield UploadFailedState();
      }
    } else if (event is SubmitHealthRecordEvent) {
      yield SubmittingState();
      try {
        // Fetch user ID from Firebase Authentication
        String userId = _auth.currentUser!.uid;

        // Add userId to the recordData
        event.recordData['user_id'] = userId;

        // Add the health record to Firestore
        await _firestore.collection('health_records').add(event.recordData);
        yield SubmittedState();
      } catch (e) {
        yield SubmissionFailedState();
      }
    }
  }
}
