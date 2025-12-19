import 'package:flutter/material.dart';

class ProfileColors {
  static const Color primary = Color(0xFF4E342E);
  static const Color accent = Color(0xFFA1887F);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF3E2723);
}

class ProfileHeaderCard extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final String email;
  final VoidCallback onEditTap;

  const ProfileHeaderCard({
    super.key,
    required this.photoUrl,
    required this.name,
    required this.email,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: ProfileColors.primary.withOpacity(0.1),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? const Icon(
                    Icons.person,
                    size: 36,
                    color: ProfileColors.primary,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ProfileColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEditTap,
            icon: const Icon(Icons.edit_outlined, color: ProfileColors.accent),
          ),
        ],
      ),
    );
  }
}

class ProfileSectionTitle extends StatelessWidget {
  final String title;

  const ProfileSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class ProfileMenuCard extends StatelessWidget {
  final List<Widget> children;

  const ProfileMenuCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool showDivider;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ProfileColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ProfileColors.primary, size: 20),
          ),
          title: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: ProfileColors.textDark,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 20,
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 60,
            color: Colors.grey[200],
          ),
      ],
    );
  }
}
