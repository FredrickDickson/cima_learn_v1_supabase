import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: ResponsivePadding.symmetric(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: ResponsiveFontSize.heading1(context),
                fontWeight: FontWeight.bold,
                color: const Color(0xFFB71C1C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: TextStyle(
                fontSize: ResponsiveFontSize.body(context),
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSection(
              context,
              'Information We Collect',
              'We collect information you provide directly to us, such as when you create an account, enroll in courses, or contact us. This may include your name, email address, and payment information.',
            ),
            
            _buildSection(
              context,
              'How We Use Your Information',
              'We use the information we collect to provide, maintain, and improve our services, process transactions, send communications, and comply with legal obligations.',
            ),
            
            _buildSection(
              context,
              'Information Sharing',
              'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy or as required by law.',
            ),
            
            _buildSection(
              context,
              'Data Security',
              'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
            ),
            
            _buildSection(
              context,
              'Course Data',
              'Your course progress, completion certificates, and learning analytics are stored securely and used to enhance your learning experience.',
            ),
            
            _buildSection(
              context,
              'Third-Party Services',
              'We use trusted third-party services including Supabase for data storage and Google for authentication. These services have their own privacy policies.',
            ),
            
            _buildSection(
              context,
              'Your Rights',
              'You have the right to access, update, or delete your personal information. You may also opt out of certain communications from us.',
            ),
            
            _buildSection(
              context,
              'Contact Us',
              'If you have questions about this Privacy Policy, please contact us at privacy@cimalearb.com.',
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveFontSize.heading3(context),
            fontWeight: FontWeight.bold,
            color: const Color(0xFFB71C1C),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: ResponsiveFontSize.body(context),
            height: 1.6,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}