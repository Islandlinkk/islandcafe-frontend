import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/announcement/data/provider/announcement_provider.dart';
import 'package:island_cafe/feature/announcement/presentation/widget/announcement_card.dart';

class AnnouncementList extends ConsumerWidget {
  const AnnouncementList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementAsyncValue = ref.watch(announcementProvider);

    return announcementAsyncValue.when(
      data: (announcements) {
        return ListView.builder(
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return AnnouncementCard(id: announcement.id, type: announcement.type, image: announcement.image, title: announcement.title, content: announcement.content);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}
