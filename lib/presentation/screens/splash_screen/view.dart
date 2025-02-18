import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../home_screen/view.dart';
import '../login_screen/view.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _showSplashAndCheckToken();
  }

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool isLoading = true;
  String? authToken;

  // Show splash screen for 2 seconds and then check token
  Future<void> _showSplashAndCheckToken() async {
    // Delay for 2 seconds
    await Future.delayed(Duration(seconds: 2));

    Future<void> _loadAuthToken() async {
      try {
        authToken = await _secureStorage.read(key: 'authToken');
        print("🔑 Retrieved Secure Token: $authToken");
      } catch (e) {
        print("❌ Secure Storage Error: ${e.toString()}");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    // Navigate based on token presence
    if (authToken != null) {
      // If token is not null, navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()), // Your home page
      );
    } else {
      // If token is null, navigate to LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginView()), // Your login page
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/logo.png', // Your logo image path
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}
