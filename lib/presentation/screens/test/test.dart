import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SendRequestPage());
  }
}

class SendRequestPage extends StatefulWidget {
  @override
  _SendRequestPageState createState() => _SendRequestPageState();
}

class _SendRequestPageState extends State<SendRequestPage> {
  final String apiUrl = 'https://integrate.api.nvidia.com/v1/chat/completions';
  final String apiKey =
      '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';

  final Map<String, String> answers = {};
  String result = '';

  // Function to send request using Dio
  Future<void> sendRequest(Map<String, String> answers) async {
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
      "content": "Please assess if the person has any chronic diseases based on the following answers: $answers",
      "role": "user"
    }
  ]
}''';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    // Printing the request headers and body
    print("Request URL: $apiUrl");
    print("Request Headers: $headers");
    print("Request Body: $requestBody");

    try {
      // Create Dio instance
      Dio dio = Dio();

      // Send POST request
      final response = await dio.post(
        apiUrl,
        data: requestBody,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        // If request is successful
        setState(() {
          result =
              response.data['choices'][0]['message']['content'] ??
              'No response';
        });
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.data}');
      } else {
        print('Request failed with status: ${response.statusCode}');
        setState(() {
          result = 'Error: Request failed with status ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Health Questionnaire')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // MCQ for Diabetes
              Text('Do you have a history of diabetes?'),
              RadioListTile<String>(
                title: Text('Yes'),
                value: 'Yes',
                groupValue: answers['diabetes'],
                onChanged: (value) {
                  setState(() {
                    answers['diabetes'] = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('No'),
                value: 'No',
                groupValue: answers['diabetes'],
                onChanged: (value) {
                  setState(() {
                    answers['diabetes'] = value!;
                  });
                },
              ),
              SizedBox(height: 20),

              // MCQ for Smoking
              Text('Do you smoke?'),
              RadioListTile<String>(
                title: Text('Yes'),
                value: 'Yes',
                groupValue: answers['smoking'],
                onChanged: (value) {
                  setState(() {
                    answers['smoking'] = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('No'),
                value: 'No',
                groupValue: answers['smoking'],
                onChanged: (value) {
                  setState(() {
                    answers['smoking'] = value!;
                  });
                },
              ),
              SizedBox(height: 20),

              // Button to submit answers
              ElevatedButton(
                onPressed: () {
                  if (answers.isNotEmpty) {
                    sendRequest(answers);
                  } else {
                    setState(() {
                      result = 'Please answer all questions';
                    });
                  }
                },
                child: Text('Submit'),
              ),
              SizedBox(height: 20),

              // Show result
              if (result.isNotEmpty)
                Text(
                  'Assessment Result: $result',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
