import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../utils/questions.dart';
import '../../color_constant/color_constant.dart';
import '../bottm nav bar/view.dart';

class HealthSymptomView extends StatefulWidget {
  const HealthSymptomView({Key? key}) : super(key: key);

  @override
  _HealthSymptomViewState createState() => _HealthSymptomViewState();
}

class _HealthSymptomViewState extends State<HealthSymptomView>
    with TickerProviderStateMixin {
  Map<String, String> answers = {};
  String result = '';
  bool isLoading = false;

  // Animation controller for result visibility
  late AnimationController _resultController;
  late Animation<double> _resultOpacity;

  @override
  void initState() {
    super.initState();
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _resultOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _resultController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _resultController.dispose();
    super.dispose();
  }

  Future<void> sendToApi() async {
    setState(() {
      isLoading = true;
    });

    final String apiUrl =
        'https://integrate.api.nvidia.com/v1/chat/completions';
    final String apiKey =
        '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';

    String answersString = '';
    answers.forEach((questionId, answer) {
      String questionText = _getQuestionTextById(questionId);
      answersString += "$questionText $answer. ";
    });

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
          _resultController.forward();
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

  String _getQuestionTextById(String questionId) {
    final question = questions.firstWhere((q) => q.id == questionId);
    return question.questionText;
  }

  String _getAnswerTextByOption(String questionId, String option) {
    final question = questions.firstWhere((q) => q.id == questionId);
    return question.options
        .firstWhere((opt) => opt.startsWith(option))
        .split(')')[1]
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button and Title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        "Health Symptom Tracker",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 20),

                // Questions List
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

                // Animated Result Section
                if (result.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _resultOpacity,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Diagnosis: $result',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 80), // Space for the bottom navigation
              ],
            ),
          ),
        ],
      ),

      // Floating Submit Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: sendToApi,
        backgroundColor: Colors.blueAccent,
        label: const Text(
          'Submit',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildQuestion(
    BuildContext context, {
    required String questionId,
    required String questionText,
    required List<String> options,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...options.map((option) {
              String optionText = _getAnswerTextByOption(questionId, option[0]);
              return RadioListTile<String>(
                title: Text(optionText),
                value: optionText,
                groupValue: answers[questionId],
                onChanged: (value) {
                  setState(() {
                    answers[questionId] = value!;
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
