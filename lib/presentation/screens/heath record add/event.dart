abstract class HealthRecordEvent {}

class SubmitHealthRecordEvent extends HealthRecordEvent {
  final Map<String, dynamic> recordData;
  SubmitHealthRecordEvent({required this.recordData});
}

class SelectTriggerEvent extends HealthRecordEvent {
  final String trigger;
  final bool isSelected;
  SelectTriggerEvent({required this.trigger, required this.isSelected});
}

class UploadFileEvent extends HealthRecordEvent {
  final String filePath;
  UploadFileEvent({required this.filePath});
}
