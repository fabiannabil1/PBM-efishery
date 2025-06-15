import 'package:intl/intl.dart';

class ChatMessage {
  final int id;
  final int chatId;
  final int senderId;
  final String senderPhone;
  final String message;
  final DateTime sentAt;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderPhone,
    required this.message,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      chatId: json['chat_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      senderPhone: json['sender_phone'] ?? '',
      message: json['message'] ?? '',
      sentAt: _parseDateTime(json['sent_at']),
    );
  }

  // Helper method to parse different date formats
  static DateTime _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();

    try {
      // Try parsing as RFC 2822 format first (e.g., "Fri, 13 Jun 2025 16:56:45 GMT")
      final rfc2822Formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
      return rfc2822Formatter.parse(dateStr.toString());
    } catch (e) {
      try {
        // Fallback to ISO 8601 format (e.g., "2025-06-13T16:56:45.000Z")
        return DateTime.parse(dateStr.toString());
      } catch (e2) {
        try {
          // Try without timezone info (e.g., "2025-06-13 16:56:45")
          final simpleFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
          return simpleFormatter.parse(dateStr.toString());
        } catch (e3) {
          // If all parsing fails, return current time
          print('Failed to parse date: $dateStr. Error: $e3');
          return DateTime.now();
        }
      }
    }
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'sender_phone': senderPhone,
      'message': message,
      'sent_at': sentAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ChatMessage{id: $id, chatId: $chatId, senderId: $senderId, senderPhone: $senderPhone, message: $message, sentAt: $sentAt}';
  }
}
