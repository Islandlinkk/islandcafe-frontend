import 'dart:convert';

import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/announcement/data/model/announcement_model.dart';
import 'package:http/http.dart' as http;

class AnnouncementService {
  Future<List<Announcement>> fetchAnnouncements() async {
    final url = Uri.parse(ApiConfig.announcement);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(
      'Failed to load announcements: ${response.statusCode} - ${response.body}',
    );
  }

  Future<Announcement> fetchAnnouncementById(String id) async {
    final url = Uri.parse(ApiConfig.announcementById(id));
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Announcement.fromJson(data);
    }
    throw Exception(
      'Failed to load announcement with id $id: ${response.statusCode} - ${response.body}',
    );
  }
}
