import 'package:collab_app/app/modules/dashboard/views/theme_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class SettingsView extends GetView<DashboardController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 32),
          _buildSettingSection(
            title: 'Account',
            children: [
              _buildSettingTile(
                title: 'Profile',
                subtitle: 'Manage your personal information',
                icon: Icons.person_rounded,
                onTap: () => Get.toNamed('/profile'),
              ),
              _buildSettingTile(
                title: 'Notifications',
                subtitle: 'Configure notification preferences',
                icon: Icons.notifications_rounded,
                onTap: () {},
              ),
              _buildSettingTile(
                title: 'Security',
                subtitle: 'Manage your security settings',
                icon: Icons.security_rounded,
                onTap: () {},
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingSection(
            title: 'Preferences',
            children: [
              _buildSettingTile(
                title: 'Theme',
                subtitle: 'Customize app appearance',
                icon: Icons.palette_rounded,
                onTap: () => Get.to(() => const ThemeSettingsView()),
              ),
              _buildSettingTile(
                title: 'Language',
                subtitle: 'Change app language',
                icon: Icons.language_rounded,
                onTap: () {},
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingSection(
            title: 'About',
            children: [
              _buildSettingTile(
                title: 'App Version',
                subtitle: 'Current version',
                icon: Icons.info_rounded,
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                onTap: () {},
              ),
              _buildSettingTile(
                title: 'Terms of Service',
                subtitle: 'Read our terms of service',
                icon: Icons.description_rounded,
                onTap: () {},
              ),
              _buildSettingTile(
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                icon: Icons.privacy_tip_rounded,
                onTap: () {},
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.teal.shade300,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          trailing: trailing ??
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 20,
              ),
          onTap: onTap,
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 68,
            endIndent: 20,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }
}
