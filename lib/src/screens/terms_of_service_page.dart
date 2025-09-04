import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
              'Terms of Service',
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
              'Acceptance of Terms',
              'By accessing and using CIMA Learn, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            
            _buildSection(
              context,
              'Course Access and Enrollment',
              'Upon enrollment and payment, you will receive access to course materials for the duration specified. Course access may be revoked for violation of these terms.',
            ),
            
            _buildSection(
              context,
              'Payment Terms',
              'All course fees are due at the time of enrollment. Payments are processed securely through our payment partners. Refunds are subject to our refund policy.',
            ),
            
            _buildSection(
              context,
              'Intellectual Property',
              'All course content, including videos, materials, and assessments, are the intellectual property of CIMA Learn and its instructors. Unauthorized sharing or distribution is prohibited.',
            ),
            
            _buildSection(
              context,
              'User Conduct',
              'Users must conduct themselves professionally and respectfully. Harassment, spam, or inappropriate behavior will result in account suspension.',
            ),
            
            _buildSection(
              context,
              'Certificates and Credentials',
              'Course completion certificates are issued upon successful completion of all course requirements. Certificates are for educational purposes and may not imply professional accreditation.',
            ),
            
            _buildSection(
              context,
              'Limitation of Liability',
              'CIMA Learn shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the service.',
            ),
            
            _buildSection(
              context,
              'Service Availability',
              'We strive to maintain service availability but do not guarantee uninterrupted access. Maintenance and updates may temporarily affect service availability.',
            ),
            
            _buildSection(
              context,
              'Termination',
              'We reserve the right to terminate or suspend access to our service immediately, without prior notice, for conduct that we believe violates these Terms.',
            ),
            
            _buildSection(
              context,
              'Contact Information',
              'For questions about these Terms of Service, please contact us at legal@cimalearb.com.',
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