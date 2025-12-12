class Announcement {
  final String id;
  final String type;
  final String image;
  final String title;
  final String content;
  final bool isActive;
  final DateTime createdAt;

  const Announcement({
    required this.id,
    required this.type,
    required this.image,
    required this.title,
    required this.content,
    required this.isActive,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      type: json['type'] as String? ?? '',
      image: json['image'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
