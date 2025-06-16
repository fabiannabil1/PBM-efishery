import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ChatService {
  static final String _baseUrl = Constants.apiUrl;

  static Future<Map<String, dynamic>> getChats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/chats/getmessage'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'chats': data['data']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to load chats',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getMessages(
    String token,
    int partnerId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/chats/$partnerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'chat_id': data['chat_id'],
          'messages': data['messages'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to load messages',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> sendMessage(
    String token,
    String receiverPhone,
    String message,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/chats/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'receiver_phone': receiverPhone,
          'message': message,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to send message',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserByPhone(
    String token,
    String phone,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/chats/search/$phone'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'user': data['data']};
      } else {
        return {'success': false, 'message': data['error'] ?? 'User not found'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
