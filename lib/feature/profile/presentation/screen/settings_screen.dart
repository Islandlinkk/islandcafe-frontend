import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/core/route/route_name.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Colors.grey[100]!;
    final divider = Colors.grey[300]!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.black,
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _SettingsCard(
              surface: surface,
              divider: divider,
              children: [
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  trailing: const Text(
                    'English',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsCard(
              surface: surface,
              divider: divider,
              children: [
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: 'FAQs',
                  onTap: () => context.push(FAQsRoute),
                
                ),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () => context.push(TermsAndConditionsRoute),
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  onTap: () => context.push(AboutUsRoute),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsCard(
              surface: surface,
              divider: divider,
              children: [
                _SettingsTile(title: 'Share the App', onTap: () {}),
                _SettingsTile(title: 'Write a Review', onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final Color surface;
  final Color divider;

  const _SettingsCard({
    required this.children,
    required this.surface,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i != 0)
              Divider(height: 1, thickness: 0.8, indent: 56, color: divider),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24, color: Colors.grey[700]),
              const SizedBox(width: 16),
            ],
            Expanded(child: Text(title, style: titleStyle)),
            if (trailing != null) ...[
              DefaultTextStyle(
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                child: trailing!,
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
