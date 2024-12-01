import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class SettingsView extends GetView<DashboardController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildSettingSection(
          title: 'Account',
          children: [
            _buildSettingTile(
              title: 'Profile',
              icon: Icons.person,
              onTap: () {},
            ),
            _buildSettingTile(
              title: 'Notifications',
              icon: Icons.notifications,
              onTap: () {},
            ),
            _buildSettingTile(
              title: 'Security',
              icon: Icons.security,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSettingSection(
          title: 'Preferences',
          children: [
            _buildSettingTile(
              title: 'Theme',
              icon: Icons.palette,
              onTap: () {},
            ),
            _buildSettingTile(
              title: 'Language',
              icon: Icons.language,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSettingSection(
          title: 'About',
          children: [
            _buildSettingTile(
              title: 'App Version',
              icon: Icons.info,
              trailing: const Text('1.0.0'),
              onTap: () {},
            ),
            _buildSettingTile(
              title: 'Terms of Service',
              icon: Icons.description,
              onTap: () {},
            ),
            _buildSettingTile(
              title: 'Privacy Policy',
              icon: Icons.privacy_tip,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required String title,
    required IconData icon,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 