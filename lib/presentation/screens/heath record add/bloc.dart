import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'event.dart';
import 'state.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecordBloc extends Bloc<HealthRecordEvent, HealthRecordState> {
  HealthRecordBloc() : super(HealthRecordInitial());

  @override
  Stream<HealthRecordState> mapEventToState(HealthRecordEvent event) async* {
    if (event is SubmitHealthRecordEvent) {
      yield* _mapSubmitHealthRecordToState(event.recordData);
    } else if (event is SelectTriggerEvent) {
      yield* _mapSelectTriggerToState(event.trigger, event.isSelected);
    } else if (event is UploadFileEvent) {
      yield* _mapUploadFileToState(event.filePath);
    }
  }

  Stream<HealthRecordState> _mapSubmitHealthRecordToState(
    Map<String, dynamic> recordData,
  ) async* {
    try {
      yield HealthRecordSubmitting();

      // Add user_id to the record data
      String userId = FirebaseAuth.instance.currentUser!.uid;
      recordData['user_id'] = userId;

      // Add the health record to Firestore
      await FirebaseFirestore.instance
          .collection('health_records')
          .add(recordData);
      yield HealthRecordSubmitted(message: "Record submitted successfully!");
    } catch (e) {
      yield HealthRecordError(error: "Error submitting record: $e");
    }
  }

  Stream<HealthRecordState> _mapSelectTriggerToState(
    String trigger,
    bool isSelected,
  ) async* {
    // You can manage selectedTriggers here if necessary
    yield HealthRecordTriggersUpdated(selectedTriggers: {trigger: isSelected});
  }

  Stream<HealthRecordState> _mapUploadFileToState(String filePath) async* {
    try {
      File file = File(filePath);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref('uploads/$fileName.jpg')
          .putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      yield HealthRecordFileUploaded(fileUrl: downloadUrl);
    } catch (e) {
      yield HealthRecordError(error: "Error uploading file: $e");
    }
  }
}
