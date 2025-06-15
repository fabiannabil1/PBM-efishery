// class Chat {
//   final int chatId;
//   final int partnerId;
//   final String partnerPhone;
//   final String partnerName;
//   final String? profilePicture;
//   final String? lastMessage;
//   final DateTime? sentAt;

//   Chat({
//     required this.chatId,
//     required this.partnerId,
//     required this.partnerPhone,
//     required this.partnerName,
//     this.profilePicture,
//     this.lastMessage,
//     this.sentAt,
//   });

//   factory Chat.fromJson(Map<String, dynamic> json) {
//     return Chat(
//       chatId: json['chat_id'] ?? 0,
//       partnerId: json['partner_id'] ?? 0,
//       partnerPhone: json['partner_phone'] ?? '',
//       partnerName: json['partner_name'] ?? '',
//       profilePicture: json['profile_picture'],
//       lastMessage: json['last_message'],
//       sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
//     );
//   }
// }

import 'package:intl/intl.dart';

class Chat {
  final int chatId;
  final int partnerId;
  final String partnerPhone;
  final String partnerName;
  final String? profilePicture;
  final String? lastMessage;
  final DateTime? sentAt;

  Chat({
    required this.chatId,
    required this.partnerId,
    required this.partnerPhone,
    required this.partnerName,
    this.profilePicture,
    this.lastMessage,
    this.sentAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chat_id'] ?? 0,
      partnerId: json['partner_id'] ?? 0,
      partnerPhone: json['partner_phone'] ?? '',
      partnerName: json['partner_name'] ?? '',
      profilePicture: json['profile_picture'],
      lastMessage: json['last_message'],
      sentAt: json['sent_at'] != null ? _parseDateTime(json['sent_at']) : null,
    );
  }

  // Shared date parsing method for both classes
  static DateTime? _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return null;

    try {
      // Try parsing as RFC 2822 format
      final formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
      return formatter.parse(dateStr.toString());
    } catch (e) {
      try {
        // Fallback to ISO 8601 format
        return DateTime.parse(dateStr.toString());
      } catch (e2) {
        // If parsing fails for nullable DateTime, return null
        return null;
      }
    }
  }
}
