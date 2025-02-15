abstract class HealthRecordState {}

class HealthRecordInitial extends HealthRecordState {}

class HealthRecordSubmitting extends HealthRecordState {}

class HealthRecordSubmitted extends HealthRecordState {
  final String message;
  HealthRecordSubmitted({required this.message});
}

class HealthRecordError extends HealthRecordState {
  final String error;
  HealthRecordError({required this.error});
}

class HealthRecordFileUploaded extends HealthRecordState {
  final String fileUrl;
  HealthRecordFileUploaded({required this.fileUrl});
}

class HealthRecordTriggersUpdated extends HealthRecordState {
  final Map<String, bool> selectedTriggers;
  HealthRecordTriggersUpdated({required this.selectedTriggers});
}
