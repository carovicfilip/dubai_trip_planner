import 'package:material_ui/material_ui.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms of Use',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Color(0xFF101A26),
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
                title: 'Acceptance of Terms',
                content:
                    'By downloading, installing, accessing, or using the Dubai Trip Planner mobile application ("App"), you agree to be bound by these Terms of Use ("Terms"). If you do not agree to these Terms, please do not use the App.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Description of Service',
                content:
                    'Dubai Trip Planner is a mobile application that helps users plan trips to Dubai, United Arab Emirates. The App provides:\n\n'
                    '• Personalized itinerary generation\n'
                    '• Information about attractions, restaurants, and activities\n'
                    '• Category-based place recommendations\n'
                    '• Favorite place management\n'
                    '• Trip planning tools and features',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Use of the App',
                content:
                    'You agree to use the App only for lawful purposes and in accordance with these Terms. You agree not to:\n\n'
                    '• Use the App in any way that violates applicable laws or regulations\n'
                    '• Attempt to gain unauthorized access to the App or its related systems\n'
                    '• Interfere with or disrupt the App\'s operation\n'
                    '• Use automated systems or bots to access the App\n'
                    '• Copy, modify, or distribute the App without permission',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Content and Information',
                content:
                    'While we strive to provide accurate and up-to-date information about Dubai attractions, restaurants, and activities, we cannot guarantee the accuracy, completeness, or timeliness of all information. Opening hours, prices, availability, and other details may change without notice. You should verify important information independently before making travel arrangements.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'AI-Generated Itineraries',
                content:
                    'The App may use artificial intelligence to generate trip itineraries based on your preferences. These itineraries are suggestions only and should not be considered as professional travel advice. We are not responsible for the quality, accuracy, or suitability of AI-generated recommendations. Always exercise your own judgment when planning your trip.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Intellectual Property',
                content:
                    'The App and its original content, features, and functionality are owned by us and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws. You may not reproduce, distribute, modify, or create derivative works of the App without our express written permission.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'User-Generated Content',
                content:
                    'You retain ownership of any content you create within the App, such as saved trips, favorites, and preferences. By using the App, you grant us a non-exclusive, worldwide, royalty-free license to use, store, and process this content solely for the purpose of providing and improving the App\'s services.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Limitation of Liability',
                content:
                    'TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING BUT NOT LIMITED TO LOSS OF PROFITS, DATA, OR OTHER INTANGIBLE LOSSES, RESULTING FROM YOUR USE OF THE APP. We are not responsible for any travel arrangements, bookings, or experiences you may make based on App recommendations.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Disclaimer of Warranties',
                content:
                    'THE APP IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED. We disclaim all warranties, including but not limited to implied warranties of merchantability, fitness for a particular purpose, and non-infringement. We do not warrant that the App will be uninterrupted, secure, or error-free.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Indemnification',
                content:
                    'You agree to indemnify, defend, and hold harmless us and our officers, directors, employees, and agents from any claims, damages, losses, liabilities, and expenses (including attorneys\' fees) arising out of or relating to your use of the App or violation of these Terms.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Termination',
                content:
                    'We reserve the right to terminate or suspend your access to the App immediately, without prior notice or liability, for any reason, including if you breach these Terms. Upon termination, your right to use the App will cease immediately.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Changes to Terms',
                content:
                    'We reserve the right to modify or replace these Terms at any time. If we make material changes, we will notify you by updating the "Last Updated" date. Your continued use of the App after any changes constitutes acceptance of the new Terms.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Governing Law',
                content:
                    'These Terms shall be governed by and construed in accordance with the laws of the United Arab Emirates, without regard to its conflict of law provisions. Any disputes arising from these Terms or your use of the App shall be subject to the exclusive jurisdiction of the courts of Dubai, UAE.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Contact Information',
                content: 'If you have any questions about these Terms of Use, please contact us at:\n\n'
                    'Email: support@dubaitripplanner.com\n\n'
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
