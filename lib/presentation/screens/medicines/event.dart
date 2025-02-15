// Events
abstract class MedicationEvent {}

class AddMedicationEvent extends MedicationEvent {
  final String medicationName;
  final int dosage;
  final String frequency;
  final String reminderTime;
  final bool repeatDaily;
  final DateTime startDate;

  AddMedicationEvent({
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.reminderTime,
    required this.repeatDaily,
    required this.startDate,
  });
}
