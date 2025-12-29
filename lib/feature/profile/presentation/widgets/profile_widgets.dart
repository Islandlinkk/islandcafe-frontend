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
        color: Colors.grey[600],
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
                    style: const TextStyle(
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
    return Column(
      children: [
        const Center(
          child: Text(
            'Stay connected!',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('https://www.facebook.com/')),
              child: const SocialIcon(
                icon: Icons.facebook,
                background: Color(0xFFEEEEEE),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('https://www.tiktok.com/')),
              child: const SocialIcon(
                icon: Icons.tiktok,
                background: Color(0xFFEEEEEE),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('https://t.me/')),
              child: const SocialIcon(
                icon: Icons.telegram,
                background: Color(0xFFEEEEEE),
              ),
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
      child: Icon(icon, color: Colors.grey[700], size: 22),
    );
  }
}
class ProfileHero extends StatelessWidget {
  final User user;
  const ProfileHero({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
              image: user.photoURL != null
                  ? DecorationImage(
                      image: NetworkImage(user.photoURL!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user.photoURL == null
                ? const Icon(Icons.person, size: 40, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            user.displayName ?? 'Coffee Lover',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => context.push('/edit-profile'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              backgroundColor: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('View Profile'),
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'Select Platform',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
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
    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.grey[700]),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
