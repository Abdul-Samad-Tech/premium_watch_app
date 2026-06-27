import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  themeProvider.isDarkMode
                      ? 'Dark theme enabled'
                      : 'Light theme enabled',
                ),
                value: themeProvider.isDarkMode,
                activeThumbColor: AppColors.accent,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value ? 'Dark mode enabled' : 'Light mode enabled',
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const Divider(),
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: Text(
              'Push Notifications',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Receive order updates and promotions'),
            value: _notificationsEnabled,
            activeThumbColor: AppColors.accent,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(),
          _buildSectionHeader('Security'),
          SwitchListTile(
            title: Text(
              'Biometric Authentication',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Use fingerprint or face ID'),
            value: _biometricEnabled,
            activeThumbColor: AppColors.accent,
            onChanged: (value) {
              setState(() {
                _biometricEnabled = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Biometric enabled' : 'Biometric disabled',
                  ),
                ),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader('Preferences'),
          ListTile(
            title: Text(
              'Language',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageSelector(),
          ),
          ListTile(
            title: Text(
              'Currency',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(_selectedCurrency),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showCurrencySelector(),
          ),
          const Divider(),
          _buildSectionHeader('Data & Storage'),
          ListTile(
            title: Text(
              'Clear Cache',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Free up storage space'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
          ),
          ListTile(
            title: Text(
              'Privacy Policy',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening privacy policy...')),
              );
            },
          ),
          ListTile(
            title: Text(
              'Terms of Service',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening terms of service...')),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'App Version: 1.0.0',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
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

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Select Language', style: GoogleFonts.playfairDisplay()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'German', 'Arabic']
              .map(
                (lang) => RadioListTile<String>(
                  title: Text(lang),
                  value: lang,
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                    Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showCurrencySelector() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Select Currency', style: GoogleFonts.playfairDisplay()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['USD', 'EUR', 'GBP', 'AED', 'PKR']
              .map(
                (currency) => RadioListTile<String>(
                  title: Text(currency),
                  value: currency,
                  groupValue: _selectedCurrency,
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value!;
                    });
                    Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
