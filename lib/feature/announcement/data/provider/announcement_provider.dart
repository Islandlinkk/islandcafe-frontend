import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:island_cafe/feature/announcement/data/model/announcement_model.dart';
import 'package:island_cafe/feature/announcement/service/announcement_service.dart';

final announcementProvider = FutureProvider<List<Announcement>>((ref) async {
  final service = AnnouncementService();
  final announcements = await service.fetchAnnouncements();
  final activeAnnouncements = announcements
      .where((announcement) => announcement.isActive == true)
      .toList();
  return activeAnnouncements;
});

final selectedAnnouncementId = StateProvider<String>((ref) => "");

final announcementHomepageProvider = FutureProvider<List<Announcement>>((
  ref,
) async {
  final service = AnnouncementService();
  final announcements = await service.fetchAnnouncements();
  final activeAnnouncements = announcements
      .where((announcement) => announcement.isActive == true)
      .take(3)
      .toList();
  return activeAnnouncements;
});

final announcementDetailProvider = FutureProvider<Announcement>((ref) async {
  final service = AnnouncementService();
  String announcementId = ref.watch(selectedAnnouncementId);
  final announcement = await service.fetchAnnouncementById(announcementId);
  return announcement;
});
