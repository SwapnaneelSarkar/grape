import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../utils/questions.dart';

class HealthSymptomView extends StatefulWidget {
  const HealthSymptomView({Key? key}) : super(key: key);

  @override
  _HealthSymptomViewState createState() => _HealthSymptomViewState();
}

class _HealthSymptomViewState extends State<HealthSymptomView> {
  // To store answers in the form of questionId: selectedOption
  Map<String, String> answers = {};

  // API result
  String result = '';
  bool isLoading = false;

  // Function to send answers to the API
  Future<void> sendToApi() async {
    setState(() {
      isLoading = true;
    });

    final String apiUrl =
        'https://integrate.api.nvidia.com/v1/chat/completions';
    final String apiKey =
        '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';

    // Build the answer string from question and answer
    String answersString = '';
    answers.forEach((questionId, answer) {
      String questionText = _getQuestionTextById(questionId);
      answersString += "$questionText $answer. ";
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

    // Debugging: Print the request payload being sent
    print("Request Payload: $requestBody");

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

      setState(() {
        isLoading = false;
        if (response.statusCode == 200) {
          result =
              response.data['choices'][0]['message']['content'] ??
              'No response';
        } else {
          result = 'Error: Request failed with status ${response.statusCode}';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        result = 'Error: $e';
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Symptom Tracker'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children:
                    questions.map((question) {
                      return _buildQuestion(
                        context,
                        questionId: question.id,
                        questionText: question.questionText,
                        options: question.options,
                      );
                    }).toList(),
              ),
            ),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: () {
                    sendToApi();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ), // Button color
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
            if (result.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Diagnosis: $result',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Build the question widget with options (radio buttons)
  Widget _buildQuestion(
    BuildContext context, {
    required String questionId,
    required String questionText,
    required List<String> options,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...options.map((option) {
              // Get the answer text for the option (e.g., "Option A text")
              String optionText = _getAnswerTextByOption(questionId, option[0]);
              return RadioListTile<String>(
                title: Text(optionText),
                value: optionText, // Use full answer text as value
                groupValue:
                    answers[questionId], // Set the group value to the current answer
                onChanged: (value) {
                  setState(() {
                    // Store the full answer text, not just 'A', 'B', or 'C'
                    answers[questionId] = value!;
                    // Debugging: Print the selected option for the current question
                    print("Selected Answer for $questionId: $value");
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
