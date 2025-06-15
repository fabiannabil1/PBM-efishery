class ArticleModel {
  final int id;
  final String title;
  final String content;
  final String authorName;
  final String createdAt;
  final String? imageUrl;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
    this.imageUrl,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorName: json['author_name'] ?? 'Admin',
      createdAt: json['created_at'] ?? '',
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author_name': authorName,
      'created_at': createdAt,
      'image_url': imageUrl,
    };
  }
}
