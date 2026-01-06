import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get _baseUrl {
    final url = dotenv.env['PUBLIC_API_URL'].toString();
    if (url.isEmpty) {
      throw Exception('PUBLIC_API_URL is not set in .env');
    }
    return url;
  }

  // Product
  static String get products => '$_baseUrl/product';
  static String productById(String id) => '$_baseUrl/product/$id';

  // Category
  static String get categories => '$_baseUrl/category';
  static String categoryById(String id) => '$_baseUrl/category/$id';

  // Billboard
  static String get billboard => '$_baseUrl/billboard';

  // Announcement
  static String get announcement => '$_baseUrl/announcement';
  static String announcementById(String id) => '$_baseUrl/announcement/$id';

  //ice
  static String get ice => '$_baseUrl/ice';

  //extra-shot
  static String get extraShot => '$_baseUrl/extra-shot';

  //size
  static String get size => '$_baseUrl/size';

  //sugar
  static String get sugar => '$_baseUrl/sugar';
  // Voucher
  static String get baseUrl => _baseUrl; 
  static String get voucher => '$_baseUrl/voucher';

  // Feedback
  static String get feedback => '$_baseUrl/feedback';

  // Account
  static String get account => '$_baseUrl/account';
  static String accountById(String id) => '$_baseUrl/account/$id';
}
