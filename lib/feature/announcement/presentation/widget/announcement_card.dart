import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/feature/announcement/data/provider/announcement_provider.dart';

class AnnouncementCard extends ConsumerWidget {
  final String id;
  final String type;
  final String image;
  final String title;
  final String content;

  const AnnouncementCard({
    super.key,
    required this.id,
    required this.type,
    required this.image,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get Dynamic Theme Data
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        // 2. Hide shadow in Dark Mode (use border instead if needed), show in Light Mode
        boxShadow: isDarkMode 
            ? [] 
            : [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
        // Optional: Add a thin border in dark mode to separate card from background
        border: isDarkMode ? Border.all(color: theme.dividerColor) : null,
      ),
      child: InkWell(
        onTap: () => {
          ref.read(selectedAnnouncementId.notifier).state = id,
          context.pushNamed('/announcementDetail'),
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    // 3. Dynamic Placeholder Color
                    color: colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image_not_supported, 
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}