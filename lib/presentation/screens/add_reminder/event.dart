import 'package:equatable/equatable.dart';

class MedicineReminderEvent extends Equatable {
  const MedicineReminderEvent();

  @override
  List<Object?> get props => [];
}

class MedicineReminderAdded extends MedicineReminderEvent {
  final String medicineName;
  final DateTime time; // Use DateTime instead of String
  final String frequency; // Add the frequency parameter

  const MedicineReminderAdded({
    required this.medicineName,
    required this.time, // Update to accept DateTime
    required this.frequency, // Include the frequency parameter
  });

  @override
  List<Object?> get props => [medicineName, time, frequency]; // Add frequency to props
}
