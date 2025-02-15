abstract class HealthRecordState {}

class HealthRecordInitial extends HealthRecordState {}

class UploadingState extends HealthRecordState {}

class UploadedState extends HealthRecordState {
  final String downloadUrl;
  UploadedState(this.downloadUrl);
}

class UploadFailedState extends HealthRecordState {}

class SubmittingState extends HealthRecordState {}

class SubmittedState extends HealthRecordState {}

class SubmissionFailedState extends HealthRecordState {}
