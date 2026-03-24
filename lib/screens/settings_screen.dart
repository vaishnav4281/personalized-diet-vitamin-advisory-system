import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('General Settings'),
            const SizedBox(height: 16),
            _buildSwitchItem(Icons.notifications_outlined, 'Enable Notifications', _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v)),
            _buildMenuItem(Icons.dark_mode_outlined, 'Dark Theme', 'Coming soon'),
            const SizedBox(height: 32),
            _buildSectionTitle('Account'),
            const SizedBox(height: 16),
            _buildMenuItem(Icons.lock_reset_outlined, 'Change Password', ''),
            _buildMenuItem(Icons.email_outlined, 'Update Email', ''),
            const SizedBox(height: 32),
            _buildSectionTitle('NutriFlow'),
            const SizedBox(height: 16),
            _buildMenuItem(Icons.info_outline, 'About Us', ''),
            _buildMenuItem(Icons.description_outlined, 'Terms of Service', ''),
            _buildMenuItem(Icons.contact_support_outlined, 'Contact Support', ''),
            _buildMenuItem(Icons.new_releases_outlined, 'What\'s New', ''),
            const SizedBox(height: 32),
            const Center(child: Text('Version 1.0.0', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildSwitchItem(IconData icon, String title, bool val, ValueChanged<bool> onChange) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Switch(value: val, onChanged: onChange, activeThumbColor: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String trailing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(trailing, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        onTap: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
