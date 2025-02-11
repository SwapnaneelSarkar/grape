import 'package:equatable/equatable.dart';

abstract class HealthSymptomEvent extends Equatable {
  const HealthSymptomEvent();

  @override
  List<Object?> get props => [];
}

class AnswerChanged extends HealthSymptomEvent {
  final String questionId;
  final String answer;

  const AnswerChanged({required this.questionId, required this.answer});

  @override
  List<Object?> get props => [questionId, answer];
}

class SubmitAnswers extends HealthSymptomEvent {}
