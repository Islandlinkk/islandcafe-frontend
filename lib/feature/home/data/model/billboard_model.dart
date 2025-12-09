class Billboard {
  final String id;
  final String image;
  final String title;
  final String link;
  final bool isActive;
  final DateTime createdAt;

  const Billboard({
    required this.id,
    required this.image,
    required this.title,
    required this.link,
    required this.isActive,
    required this.createdAt,
  });

  factory Billboard.fromJson(Map<String, dynamic> json) {
    return Billboard(
      id: json['id'] as String,
      image: json['image'] as String,
      title: json['title'] as String? ?? '',
      link: json['link'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
