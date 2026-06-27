import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Contact Us'),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accent.withValues(alpha:0.1),
              child: const Icon(Icons.email, color: AppColors.accent),
            ),
            title: Text(
              'Email Support',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('support@luxetime.com'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _launchURL('mailto:support@luxetime.com'),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accent.withValues(alpha:0.1),
              child: const Icon(Icons.phone, color: AppColors.accent),
            ),
            title: Text(
              'Phone Support',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('+1 (555) 123-4567'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _launchURL('tel:+15551234567'),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accent.withValues(alpha:0.1),
              child: const Icon(Icons.chat, color: AppColors.accent),
            ),
            title: Text(
              'Live Chat',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Available 24/7'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Live chat coming soon!')),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader('FAQs'),
          _buildFAQItem(
            'How do I track my order?',
            'You can track your order from the "My Orders" section in your profile. Once your order is shipped, you\'ll receive a tracking number via email.',
          ),
          _buildFAQItem(
            'What is the return policy?',
            'We offer a 30-day return policy for all unused items in their original packaging. Refunds are processed within 5-7 business days.',
          ),
          _buildFAQItem(
            'How long does shipping take?',
            'Standard shipping takes 5-7 business days. Express shipping is available and takes 2-3 business days.',
          ),
          _buildFAQItem(
            'Do you offer international shipping?',
            'Yes, we ship to over 50 countries worldwide. Shipping costs vary by destination.',
          ),
          _buildFAQItem(
            'How can I cancel my order?',
            'You can cancel your order within 24 hours of placing it. Go to "My Orders" and select the order you wish to cancel.',
          ),
          const Divider(),
          _buildSectionHeader('Quick Links'),
          ListTile(
            leading: const Icon(Icons.local_shipping_outlined, color: AppColors.accent),
            title: Text(
              'Shipping Information',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening shipping information...')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined, color: AppColors.accent),
            title: Text(
              'Return Policy',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening return policy...')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined, color: AppColors.accent),
            title: Text(
              'Warranty Information',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening warranty information...')),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Still need help?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our support team is here to assist you',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchURL('mailto:support@luxetime.com'),
                    icon: const Icon(Icons.email),
                    label: const Text('Contact Support'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
