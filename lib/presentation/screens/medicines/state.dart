abstract class MedicationState {}

class MedicationInitialState extends MedicationState {}

class MedicationLoadingState extends MedicationState {}

class MedicationAddedState extends MedicationState {}

class MedicationErrorState extends MedicationState {
  final String error;

  MedicationErrorState({required this.error});
}
