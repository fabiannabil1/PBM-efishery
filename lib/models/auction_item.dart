import 'package:intl/intl.dart';

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
    DateTime parseDate(String dateStr) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        // Try parsing RFC 1123 format like "Tue, 03 Jun 2025 00:23:11 GMT"
        return DateFormat(
          "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
          'en_US',
        ).parseUtc(dateStr);
      }
    }

    return AuctionItem(
      id: json['id'] ?? 0, // Default to 0 if null
      title: json['title'] ?? '', // Default to empty string if null
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '', // Default to empty string if null
      status: json['status'] ?? '',
      currentPrice: json['current_price'] ?? '0',
      startingPrice: json['starting_price'] ?? '0',
      createdAt: parseDate(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      deadline: parseDate(json['deadline'] ?? DateTime.now().toIso8601String()),
      locationId: json['location_id'] ?? 0,
      locationName: json['location_name'] ?? '',
      userId: json['user_id'] ?? 0,
      winnerId: json['winner_id'], // Nullable, no default needed
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
