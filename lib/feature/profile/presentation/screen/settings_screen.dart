import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/core/route/route_name.dart';
import 'package:island_cafe/feature/theme/theme_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen to the current theme
    final currentTheme = ref.watch(themeProvider);

    // Get colors from the theme (Dynamic!)
    final surface = Theme.of(context).cardColor;
    final divider = Theme.of(context).dividerColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          // Use semantic color, not hardcoded black
          color: Theme.of(context).colorScheme.onSurface,
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Theme.of(context).appBarTheme.foregroundColor,
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
                  // 2. Show the current mode name (e.g., "System")
                  trailing: Text(
                    currentTheme.name.capitalize(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  // 3. Open the selector
                  onTap: () => _showAppearanceSheet(context, ref, currentTheme),
                ),
                _SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  trailing: Text(
                    'English',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
            // ... (Rest of your code remains the same: FAQs, Share, etc.)
            const SizedBox(height: 20),
            _SettingsCard(
              surface: surface,
              divider: divider,
              children: [
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: 'FAQs',
                  onTap: () => context.push(faqsRoute),
                ),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () => context.push(termsAndConditionsRoute),
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  onTap: () => context.push(aboutUsRoute),
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

  // --- THE BOTTOM SHEET ---
  void _showAppearanceSheet(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Choose Appearance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _ThemeOption(
                label: 'System Default',
                mode: ThemeMode.system,
                isSelected: currentMode == ThemeMode.system,
                onTap: (mode) {
                  ref.read(themeProvider.notifier).setTheme(mode);
                  context.pop();
                },
              ),
              _ThemeOption(
                label: 'Light Mode',
                mode: ThemeMode.light,
                isSelected: currentMode == ThemeMode.light,
                onTap: (mode) {
                  ref.read(themeProvider.notifier).setTheme(mode);
                  context.pop();
                },
              ),
              _ThemeOption(
                label: 'Dark Mode',
                mode: ThemeMode.dark,
                isSelected: currentMode == ThemeMode.dark,
                onTap: (mode) {
                  ref.read(themeProvider.notifier).setTheme(mode);
                  context.pop();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

// --- HELPER WIDGET FOR OPTIONS ---
class _ThemeOption extends StatelessWidget {
  final String label;
  final ThemeMode mode;
  final bool isSelected;
  final Function(ThemeMode) onTap;

  const _ThemeOption({
    required this.label,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : Icon(
              Icons.circle_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      onTap: () => onTap(mode),
    );
  }
}

// Helper to make "system" -> "System"
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// --- KEEP YOUR EXISTING _SettingsCard AND _SettingsTile CLASSES BELOW ---
// (Paste your original _SettingsCard and _SettingsTile classes here)
// (But update _SettingsTile to read color from context if you want it to support dark mode text properly)
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
              Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(child: Text(title, style: titleStyle)),
            if (trailing != null) ...[
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                child: trailing!,
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}
