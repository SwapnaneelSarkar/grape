import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON parsing
import 'package:grape/presentation/color_constant/color_constant.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import flutter_tts

class SpeechToTextChatPage extends StatefulWidget {
  @override
  _SpeechToTextChatPageState createState() => _SpeechToTextChatPageState();
}

class _SpeechToTextChatPageState extends State<SpeechToTextChatPage> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts; // Initialize FlutterTts
  bool _isListening = false;
  String _text = '';
  List<Map<String, String>> messages = [];
  bool _isPopupVisible = false; // Track popup visibility

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts(); // Initialize FlutterTts
    initTextToSpeech();
  }

  // Initialize Text-to-Speech
  Future<void> initTextToSpeech() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5); // Adjust speech rate
    setState(() {});
  }

  // Start listening to speech input
  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print("onStatus: $status");
          if (status == 'done') {
            // Close the listening popup when the status is 'done'
            _closeListeningDialog();

            // Stop listening and send the transcribed text to the API
            setState(() {
              _isListening = false;
              _isPopupVisible = false;
            });
            _sendMessageToApi(
              _text,
            ); // Send the transcribed text to API when stopped
          }
        },
        onError: (errorNotification) => print('onError: $errorNotification'),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _isPopupVisible = true; // Show the listening popup
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
            });
          },
        );
        _showListeningDialog(); // Show dialog when listening starts
      } else {
        setState(() {
          _isListening = false;
          _isPopupVisible = false; // Hide the popup
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Speech recognition unavailable")),
        );
      }
    } else {
      // Stop listening and send the transcribed text to the API
      setState(() {
        _isListening = false;
        _isPopupVisible = false; // Hide the popup when stopped
      });
      _speech.stop();
      _sendMessageToApi(_text); // Send the transcribed text to API when stopped
    }
  }

  // Call Gemini API with the user's transcribed message
  Future<void> _sendMessageToApi(String message) async {
    var apiUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyDs1Oe5TiVZAuCfmFVFHbuxLAx6BR67uZg";
    var headers = {'Content-Type': 'application/json'};

    var body = json.encode({
      'contents': [
        {
          'parts': [
            {
              'text':
                  "Act like you are an medical/health care chatbot who gives affiramtive and encouraging answers. Donot get offtopic from medical and health. Dont them what u cant do and dont tell them what u r designed for. Also give preecise and brief responses. User message: " +
                  message,
            },
          ],
        },
      ],
    });

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        _processApiResponse(responseBody);
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in API call: $e");
    }
  }

  // The function that processes the response from the API
  void _processApiResponse(dynamic response) {
    print("API Response: $response");

    if (response != null &&
        response.containsKey('candidates') &&
        response['candidates'].isNotEmpty) {
      var candidate = response['candidates'][0];
      if (candidate['content'] != null &&
          candidate['content']['parts'] != null &&
          candidate['content']['parts'].isNotEmpty) {
        String generatedText = candidate['content']['parts'][0]['text'];
        setState(() {
          messages.add({
            'role': 'assistant',
            'content': generatedText ?? 'No response content',
          });
        });

        // After generating content, speak the response
        systemSpeak(generatedText);
      } else {
        print("Error: Content parts not found in candidate");
        setState(() {
          messages.add({
            'role': 'assistant',
            'content': 'Failed to generate content. Please try again.',
          });
        });
      }
    } else {
      print("Error: API response does not contain 'candidates'");
      setState(() {
        messages.add({
          'role': 'assistant',
          'content': 'Failed to generate content. Please try again.',
        });
      });
    }
  }

  // System speak (text-to-speech)
  Future<void> systemSpeak(String content) async {
    await _flutterTts.speak(content);
  }

  // Send message to the chat
  void _sendMessage(String message) {
    setState(() {
      messages.add({'role': 'user', 'content': message});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _speech.stop();
    _flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Height of the AppBar
        child: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Center(
            child: Text(
              'Speech to Text Chat',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display messages
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  var message = messages[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          message['role'] == 'user'
                              ? Colors.blue[100]
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      message['content'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            message['role'] == 'user'
                                ? Colors.blue
                                : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Voice control and input text field
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    _startListening();
                    if (_isListening) {
                      _showListeningDialog(); // Show the dialog when listening starts
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: _text),
                    decoration: InputDecoration(
                      hintText: 'Talk to generate text...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (text) {
                      _text = text;
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: AppColors.primary),
                  onPressed: () {
                    if (_text.isNotEmpty) {
                      _sendMessage(_text);
                      _sendMessageToApi(_text);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the listening popup
  void _showListeningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Make sure the dialog cannot be dismissed
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Listening...'),
              ],
            ),
          ),
        );
      },
    );
  }

  // Close the dialog once listening is stopped
  void _closeListeningDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
