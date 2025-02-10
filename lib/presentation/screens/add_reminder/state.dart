// state.dart
import 'package:equatable/equatable.dart';

abstract class MedicineReminderState extends Equatable {
  const MedicineReminderState();

  @override
  List<Object?> get props => [];
}

class MedicineReminderInitial extends MedicineReminderState {}

class MedicineReminderLoading extends MedicineReminderState {}

class MedicineReminderSuccess extends MedicineReminderState {}

class MedicineReminderFailure extends MedicineReminderState {
  final String error;

  const MedicineReminderFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
