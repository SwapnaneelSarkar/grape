// event.dart
import 'package:equatable/equatable.dart';

class MedicineReminderEvent extends Equatable {
  const MedicineReminderEvent();

  @override
  List<Object?> get props => [];
}

class MedicineReminderAdded extends MedicineReminderEvent {
  final String medicineName;
  final DateTime time; // Use DateTime instead of String

  const MedicineReminderAdded({
    required this.medicineName,
    required this.time, // Update to accept DateTime
  });

  @override
  List<Object?> get props => [medicineName, time];
}
