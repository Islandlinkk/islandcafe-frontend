import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        letterSpacing: 0.3,
      ),
    );
  }
}

class CardGrid extends StatelessWidget {
  final List<CardItem> items;
  final Color surface;
  final Color border;
  final Color iconColor;

  const CardGrid({
    super.key,
    required this.items,
    required this.surface,
    required this.border,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = ((constraints.maxWidth - 12) / 2).floorToDouble();

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) => ShortcutCard(
                  surface: surface,
                  border: border,
                  iconColor: iconColor,
                  item: item,
                  width: itemWidth,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class CardItem {
  final IconData icon;
  final String label;
  final String? routeName;
  final VoidCallback? onTap;
  const CardItem({
    required this.icon,
    required this.label,
    this.routeName,
    this.onTap,
  });
}

class ShortcutCard extends StatelessWidget {
  final CardItem item;
  final Color surface;
  final Color border;
  final Color iconColor;
  final double width;

  const ShortcutCard({
    super.key,
    required this.item,
    required this.surface,
    required this.border,
    required this.iconColor,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return SizedBox(
      width: width,
      child: Material(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (item.onTap != null) {
              item.onTap!();
            } else if (item.routeName != null) {
              context.go(item.routeName!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Row(
              children: [
                Icon(item.icon, color: iconColor, size: 26),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    item.label,
                    style: textStyle?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SocialsSection extends StatelessWidget {
  const SocialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surfaceContainerHighest;

    return Column(
      children: [
        Center(
          child: Text(
            'Stay connected!',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('https://www.facebook.com/')),
              child: SocialIcon(icon: Icons.facebook, background: bg),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('https://www.tiktok.com/')),
              child: SocialIcon(icon: Icons.tiktok, background: bg),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('https://t.me/')),
              child: SocialIcon(icon: Icons.telegram, background: bg),
            ),
          ],
        ),
      ],
    );
  }
}

class SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color background;
  const SocialIcon({super.key, required this.icon, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      // Icon color adapts to the background
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 22,
      ),
    );
  }
}

// ==========================================
// UPDATED PROFILE HERO (Your Button Fix)
// ==========================================
class ProfileHero extends StatelessWidget {
  final User user;
  const ProfileHero({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final buttonColor = isDarkMode ? theme.colorScheme.primary : Colors.white;
    final buttonTextColor = isDarkMode
        ? theme.colorScheme.onPrimary
        : Colors.black;
    final buttonShadow = isDarkMode
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ];

    return Column(
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
              image: user.photoURL != null
                  ? DecorationImage(
                      image: NetworkImage(user.photoURL!),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        print("Error loading profile image: $exception");
                      },
                    )
                  : null,
            ),
            child: user.photoURL == null
                ? Icon(
                    Icons.person,
                    size: 40,
                    color: theme.colorScheme.onPrimaryContainer,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            user.displayName ?? 'Coffee Lover',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12), // Slightly more space
        // 2. THE NEW BUTTON
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: buttonShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => context.push('/edit-profile'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Text(
                    'View Profile',
                    style: TextStyle(
                      color: buttonTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class ShowSignOutButton extends StatelessWidget {
  const ShowSignOutButton({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Theme.of(c).cardColor, // Dynamic Dialog Background
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: TextButton.icon(
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Sign Out'),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}

void showPlatformModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const PlatformSelectionModal(),
  );
}

class PlatformSelectionModal extends StatelessWidget {
  const PlatformSelectionModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, // Dynamic Background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Select Platform',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                PlatformOption(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await launchUrl(
                      Uri.parse('https://facebook.com'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const SizedBox(height: 12),
                PlatformOption(
                  icon: Icons.telegram,
                  label: 'Telegram',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await launchUrl(
                      Uri.parse('https://t.me/HEANGDD'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class PlatformOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  const PlatformOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardColor, // Dynamic Card Color
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
