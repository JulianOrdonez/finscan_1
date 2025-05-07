import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'If you have any questions or need assistance, please feel free to contact our support team.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildSupportOption(
              context,
              icon: Icons.email,
              title: 'Email Support',
              description: 'Send us an email at support@example.com',
              onTap: () => _launchEmail(),
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              context,
              icon: Icons.phone,
              title: 'Phone Support',
              description: 'Call us at +1-123-456-7890',
              onTap: () => _launchPhone(),
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              context,
              icon: Icons.web,
              title: 'Website Support',
              description: 'Visit our website for more information',
              onTap: () => _launchWebsite(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@example.com',
      queryParameters: {'subject': 'Support Request'},
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+1-123-456-7890');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  void _launchWebsite() async {
    final Uri websiteUri = Uri(scheme: 'https', host: 'www.example.com');
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri);
    } else {
      throw 'Could not launch $websiteUri';
    }
  }
}