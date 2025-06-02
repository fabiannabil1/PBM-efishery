class AuctionItem {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String status;
  final String currentPrice;
  final String startingPrice;
  final DateTime createdAt;
  final DateTime deadline;
  final int locationId;
  final String locationName;
  final int userId;
  final int? winnerId;

  AuctionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.currentPrice,
    required this.startingPrice,
    required this.createdAt,
    required this.deadline,
    required this.locationId,
    required this.locationName,
    required this.userId,
    this.winnerId,
  });

  factory AuctionItem.fromJson(Map<String, dynamic> json) {
    return AuctionItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      status: json['status'],
      currentPrice: json['current_price'],
      startingPrice: json['starting_price'],
      createdAt: DateTime.parse(json['created_at']),
      deadline: DateTime.parse(json['deadline']),
      locationId: json['location_id'],
      locationName: json['location_name'],
      userId: json['user_id'],
      winnerId: json['winner_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'status': status,
      'current_price': currentPrice,
      'starting_price': startingPrice,
      'created_at': createdAt.toUtc().toIso8601String(),
      'deadline': deadline.toUtc().toIso8601String(),
      'location_id': locationId,
      'location_name': locationName,
      'user_id': userId,
      'winner_id': winnerId,
    };
  }
}
