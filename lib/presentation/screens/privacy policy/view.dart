import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
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
                "Privacy Policy",
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
                "This Privacy Policy explains how we collect, use, and protect your personal information when you use our app.",
                Icons.info_outline,
              ),
              const SizedBox(height: 20),

              // Section 2: Information Collection
              _buildSection(
                context,
                "Information Collection",
                "We collect personal information such as your name, email, and other data necessary for providing our services.",
                Icons.collections,
              ),
              const SizedBox(height: 20),

              // Section 3: Use of Information
              _buildSection(
                context,
                "Use of Information",
                "We use the information collected to improve our services, personalize your experience, and communicate with you effectively.",
                Icons.image,
              ),
              const SizedBox(height: 20),

              // Section 4: Sharing of Information
              _buildSection(
                context,
                "Sharing of Information",
                "We do not share your personal information with third parties except as necessary to provide our services or as required by law.",
                Icons.share,
              ),
              const SizedBox(height: 20),

              // Section 5: Security
              _buildSection(
                context,
                "Security",
                "We take reasonable steps to protect your personal information from unauthorized access, use, or disclosure.",
                Icons.lock,
              ),
              const SizedBox(height: 20),

              // Section 6: Cookies
              _buildSection(
                context,
                "Cookies",
                "We use cookies to improve user experience and analyze app usage. You can manage cookies in your settings.",
                Icons.cookie,
              ),
              const SizedBox(height: 20),

              // Section 7: Your Rights
              _buildSection(
                context,
                "Your Rights",
                "You have the right to access, correct, or delete your personal information. Contact us for any requests regarding your data.",
                Icons.account_circle_outlined,
              ),
              const SizedBox(height: 20),

              // Section 8: Changes to Privacy Policy
              _buildSection(
                context,
                "Changes to Privacy Policy",
                "We may update this Privacy Policy from time to time. Any changes will be communicated through the app.",
                Icons.update,
              ),
              const SizedBox(height: 20),

              // Section 9: Contact Us
              _buildSection(
                context,
                "Contact Us",
                "If you have any questions or concerns regarding our privacy practices, please contact us at support@example.com.",
                Icons.contact_mail,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
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
