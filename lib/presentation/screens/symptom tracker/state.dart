import 'package:equatable/equatable.dart';

abstract class HealthSymptomState extends Equatable {
  const HealthSymptomState();

  @override
  List<Object?> get props => [];
}

class HealthSymptomInitial extends HealthSymptomState {}

class HealthSymptomAnswered extends HealthSymptomState {
  final Map<String, String> answers;

  const HealthSymptomAnswered({required this.answers});

  @override
  List<Object?> get props => [answers];
}

class HealthSymptomResult extends HealthSymptomState {
  final String result;

  const HealthSymptomResult({required this.result});

  @override
  List<Object?> get props => [result];
}
