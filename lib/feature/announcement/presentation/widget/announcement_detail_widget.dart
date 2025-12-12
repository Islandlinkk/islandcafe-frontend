import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/announcement/data/provider/announcement_provider.dart';

class AnnouncementDetailWidget extends ConsumerWidget {
  const AnnouncementDetailWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementAsyncValue = ref.watch(announcementDetailProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: announcementAsyncValue.when(
          data: (announcement) => Text(
            announcement.type,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          loading: () => const Text('Loading...'),
          error: (error, stackTrace) => const Text('Error'),
        ),
      ),
      body: SafeArea(
        child: announcementAsyncValue.when(
          data: (announcement) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      announcement.image,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    announcement.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(announcement.content, style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
