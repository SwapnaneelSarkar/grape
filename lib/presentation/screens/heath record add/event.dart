import 'dart:io';

abstract class HealthRecordEvent {}

class SubmitHealthRecordEvent extends HealthRecordEvent {
  final Map<String, dynamic> recordData;

  SubmitHealthRecordEvent(this.recordData);
}

class UploadFileEvent extends HealthRecordEvent {
  final File file;
  final String fileType;

  UploadFileEvent(this.file, this.fileType);
}
