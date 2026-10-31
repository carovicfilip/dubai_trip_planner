import 'package:material_ui/material_ui.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor:   Color(0xFF101A26),
        shadowColor: Colors.black26,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'Last Updated',
                content: 'December 2024',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Introduction',
                content:
                    'Welcome to Dubai Trip Planner ("we," "our," or "us"). We are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Information We Collect',
                content:
                    'We may collect information that you provide directly to us, including:\n\n'
                    '• Trip planning data (dates, accommodation location, preferred categories)\n'
                    '• Saved favorites and itineraries\n'
                    '• Device information and usage patterns\n'
                    '• Location data (if you grant permission)',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'How We Use Your Information',
                content:
                    'We use the collected information to:\n\n'
                    '• Generate personalized trip itineraries\n'
                    '• Store your preferences and saved places\n'
                    '• Improve our services and user experience\n'
                    '• Provide relevant recommendations\n'
                    '• Analyze app usage to enhance functionality',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Data Storage',
                content:
                    'Your trip plans, favorites, and preferences are stored locally on your device. We do not transmit this data to external servers unless you explicitly choose to sync your data across devices. Location data is used only for itinerary optimization and is not shared with third parties.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Third-Party Services',
                content:
                    'Our app may integrate with third-party services for map data, weather information, and place recommendations. These services have their own privacy policies, and we encourage you to review them. We are not responsible for the privacy practices of third-party services.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Data Security',
                content:
                    'We implement appropriate technical and organizational measures to protect your personal information. However, no method of transmission over the internet or electronic storage is completely secure. While we strive to protect your data, we cannot guarantee absolute security.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Your Rights',
                content:
                    'You have the right to:\n\n'
                    '• Access your personal data stored in the app\n'
                    '• Delete your data at any time\n'
                    '• Modify your preferences\n'
                    '• Revoke location permissions through your device settings\n'
                    '• Clear all app data through device settings',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Children\'s Privacy',
                content:
                    'Our app is not intended for children under the age of 13. We do not knowingly collect personal information from children. If you become aware that a child has provided us with personal information, please contact us immediately.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Changes to This Privacy Policy',
                content:
                    'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date. You are advised to review this Privacy Policy periodically for any changes.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Contact Us',
                content:
                    'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                    'Email: privacy@dubaitripplanner.com\n\n'
                    'We will respond to your inquiry within a reasonable timeframe.',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3F57),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}

