import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/questions.dart';
import 'event.dart';
import 'state.dart';
import 'package:dio/dio.dart';

class HealthSymptomBloc extends Bloc<HealthSymptomEvent, HealthSymptomState> {
  HealthSymptomBloc() : super(HealthSymptomInitial()) {
    on<AnswerChanged>(_onAnswerChanged);
    on<SubmitAnswers>(_onSubmitAnswers);
  }

  // When the answer is changed, update the state with the full answer text
  void _onAnswerChanged(AnswerChanged event, Emitter<HealthSymptomState> emit) {
    final answers =
        (state is HealthSymptomAnswered)
            ? Map<String, String>.from((state as HealthSymptomAnswered).answers)
            : <String, String>{};

    // Fetch the full answer text based on the selected option
    String fullAnswerText = _getAnswerTextByOption(
      event.questionId,
      event.answer,
    );

    // Store the full answer text (not just the option identifier)
    answers[event.questionId] = fullAnswerText;

    // Emit the updated answers immediately after selection
    emit(HealthSymptomAnswered(answers: answers)); // This triggers UI update
  }

  Future<void> _onSubmitAnswers(
    SubmitAnswers event,
    Emitter<HealthSymptomState> emit,
  ) async {
    final currentState = state;

    if (currentState is HealthSymptomAnswered) {
      final answers = currentState.answers;

      // Send the answers to the API
      String result = await _sendToApi(answers);

      emit(HealthSymptomResult(result: result));
    }
  }

  // Send answers to the API, constructing the payload
  Future<String> _sendToApi(Map<String, String> answers) async {
    final String apiUrl =
        'https://integrate.api.nvidia.com/v1/chat/completions';
    final String apiKey =
        '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';

    // Build the answer string from question and answer
    String answersString = '';
    answers.forEach((questionId, answer) {
      String questionText = _getQuestionTextById(questionId);
      answersString +=
          "$questionText $answer. "; // Add full question text and the full answer
    });

    // Construct the request body
    final String requestBody = '''{
      "model": "writer/palmyra-fin-70b-32k",
      "temperature": 0.2,
      "top_p": 0.7,
      "frequency_penalty": 0,
      "presence_penalty": 0,
      "max_tokens": 1024,
      "stream": false,
      "messages": [
        {
          "content": "You are a health symptom tracker AI. Based on the user's responses to the following symptoms, provide a precise diagnosis. Consider only the symptoms and do not make assumptions beyond the provided information. Important: This diagnosis is based solely on symptoms. It is always recommended to consult a healthcare professional for an accurate diagnosis and treatment plan. Answers: $answersString",
          "role": "user"
        }
      ]
    }''';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    try {
      Dio dio = Dio();

      // Send the POST request
      final response = await dio.post(
        apiUrl,
        data: requestBody,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'] ??
            'No response';
      } else {
        print('Error: Request failed with status ${response.statusCode}');
        return 'Error: Request failed with status ${response.statusCode}';
      }
    } catch (e) {
      print('Error: $e');
      return 'Error: $e';
    }
  }

  // Fetch the question text by questionId
  String _getQuestionTextById(String questionId) {
    final question = questions.firstWhere((q) => q.id == questionId);
    return question.questionText;
  }

  // Map the selected option (A, B, C) to the full answer text
  String _getAnswerTextByOption(String questionId, String option) {
    final question = questions.firstWhere((q) => q.id == questionId);

    String answerText = '';
    switch (option) {
      case 'A':
        answerText =
            question.options[0]
                .split(')')[1]
                .trim(); // Get full answer text for option A
        break;
      case 'B':
        answerText =
            question.options[1]
                .split(')')[1]
                .trim(); // Get full answer text for option B
        break;
      case 'C':
        answerText =
            question.options[2]
                .split(')')[1]
                .trim(); // Get full answer text for option C
        break;
      default:
        answerText = 'Invalid option';
    }

    return answerText;
  }
}
