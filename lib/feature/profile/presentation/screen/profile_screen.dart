import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Colors.grey[100]!;
    final border = Colors.grey[300]!;
    final iconColor = Colors.grey[600]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
              child: Row(
                children: [
                  const Spacer(),
                  const Text(
                    'ACCOUNT',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {},
                    child: const Text('Log In'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
                ],
              ),
            ),

            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel(text: 'SHORTCUTS'),
                    const SizedBox(height: 12),
                    _CardGrid(
                      surface: surface,
                      border: border,
                      iconColor: iconColor,
                      items: const [
                        _CardItem(
                          icon: Icons.storefront_outlined,
                          label: 'Stores',
                        ),
                        _CardItem(
                          icon: Icons.campaign_outlined,
                          label: 'Announcements',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel(text: 'CONTACTS'),
                    const SizedBox(height: 12),
                    _CardGrid(
                      surface: surface,
                      border: border,
                      iconColor: iconColor,
                      items: const [
                        _CardItem(
                          icon: Icons.person_outline,
                          label: 'Customer Service',
                        ),
                        _CardItem(
                          icon: Icons.edit_note_outlined,
                          label: 'Feedback',
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
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
                        _SocialIcon(
                          icon: Icons.facebook,
                          background: Colors.grey[200]!,
                        ),
                        const SizedBox(width: 16),
                        _SocialIcon(
                          icon: Icons.tiktok, // placeholder for TikTok
                          background: Colors.grey[200]!,
                        ),
                        const SizedBox(width: 16),
                        _SocialIcon(
                          icon: Icons.telegram,
                          background: Colors.grey[200]!,
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

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

class _CardGrid extends StatelessWidget {
  final List<_CardItem> items;
  final Color surface;
  final Color border;
  final Color iconColor;

  const _CardGrid({
    required this.items,
    required this.surface,
    required this.border,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // two columns with 12px gap
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) => _ShortcutCard(
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

class _CardItem {
  final IconData icon;
  final String label;
  const _CardItem({required this.icon, required this.label});
}

class _ShortcutCard extends StatelessWidget {
  final _CardItem item;
  final Color surface;
  final Color border;
  final Color iconColor;
  final double width;

  const _ShortcutCard({
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
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
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color background;
  const _SocialIcon({required this.icon, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.grey[700], size: 22),
    );
  }
}
