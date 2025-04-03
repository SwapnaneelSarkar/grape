import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../home_screen/view.dart';
import '../login_screen/view.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool isLoading = true;
  String? authToken;
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
    _showSplashAndCheckToken();
  }

  Future<void> _showSplashAndCheckToken() async {
    // Delay for 2 seconds
    await Future.delayed(Duration(seconds: 2));

    try {
      authToken = await _secureStorage.read(key: 'authToken');
      print("🔑 Retrieved Secure Token: $authToken");
    } catch (e) {
      print("❌ Secure Storage Error: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });

      if (authToken != null) {
        // If token is not null, navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ), // Your home page
        );
      } else {
        // If token is null, navigate to LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginView(),
          ), // Your login page
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Image with animation
              AnimatedContainer(
                duration: Duration(seconds: 2),
                curve: Curves.easeInOut,
                child: Image.asset(
                  'assets/splash.png', // Your logo image path
                  width: 150,
                  height: 150,
                ),
              ),
              SizedBox(height: 20), // Space between image and text
              // Name under the image
              Text(
                'Grape',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A0DAD), // Purple color
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(
                height: 20,
              ), // Space before transition or loading spinner
              isLoading
                  ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF6A0DAD),
                    ), // Custom color for spinner
                  ) // Elegant loading indicator
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
