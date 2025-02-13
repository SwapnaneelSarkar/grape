import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // iOS-style back arrow
        backgroundColor:
            Colors.transparent, // Transparent background for no top bar
        elevation: 0, // No shadow
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ), // iOS-style back arrow
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with better styling
              Text(
                "Terms and Conditions",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Section 1: Introduction with Card and Icon
              _buildSection(
                context,
                "Introduction",
                "These Terms and Conditions govern your use of our application. By using this app, you agree to abide by these terms.",
                Icons.info_outline,
              ),
              const SizedBox(height: 20),

              // Section 2: User Accounts
              _buildSection(
                context,
                "User Accounts",
                "To use certain features of the app, you must create an account. You are responsible for maintaining the confidentiality of your account credentials.",
                Icons.account_circle,
              ),
              const SizedBox(height: 20),

              // Section 3: Privacy Policy
              _buildSection(
                context,
                "Privacy Policy",
                "Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and share your information.",
                Icons.security,
              ),
              const SizedBox(height: 20),

              // Section 4: Restrictions
              _buildSection(
                context,
                "Restrictions",
                "You agree not to use the app for any illegal or prohibited activities, including but not limited to distributing malware, spamming, or engaging in unauthorized access.",
                Icons.block,
              ),
              const SizedBox(height: 20),

              // Section 5: Termination
              _buildSection(
                context,
                "Termination",
                "We may terminate or suspend your access to the app at any time, without notice, for violating these terms.",
                Icons.exit_to_app,
              ),
              const SizedBox(height: 20),

              // Section 6: Changes to Terms
              _buildSection(
                context,
                "Changes to Terms",
                "We may update these Terms and Conditions from time to time. You will be notified of any significant changes.",
                Icons.update,
              ),
              const SizedBox(height: 20),

              // Section 7: Limitation of Liability
              _buildSection(
                context,
                "Limitation of Liability",
                "We are not liable for any damages arising from your use of the app, except as required by law.",
                Icons.warning,
              ),
              const SizedBox(height: 20),

              // Section 8: Governing Law
              _buildSection(
                context,
                "Governing Law",
                "These terms are governed by the laws of the jurisdiction in which we operate.",
                Icons.gavel,
              ),
              const SizedBox(height: 20),

              // Section 9: Contact Us
              _buildSection(
                context,
                "Contact Us",
                "If you have any questions about these Terms and Conditions, feel free to contact us at support@example.com.",
                Icons.contact_mail,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build each section with icon, title, and content
  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white, // No background color (flat design)
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
