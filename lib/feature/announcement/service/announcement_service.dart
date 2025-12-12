import 'dart:convert';

import 'package:island_cafe/feature/announcement/data/model/announcement_model.dart';
import 'package:http/http.dart' as http;

class AnnouncementService {
  static const _endpoint =
      "https://coffee-shop-system-two.vercel.app/api/announcement";

  Future<List<Announcement>> fetchAnnouncements() async {
    final url = Uri.parse(_endpoint);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Announcement.fromJson(json)).toList();
    }
    throw Exception('Failed to load announcements');
  }

  Future<Announcement> fetchAnnouncementById(String id) async {
    final url = Uri.parse("$_endpoint/$id");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Announcement.fromJson(data);
    }
    throw Exception('Failed to load announcement with id $id');
  }
}
