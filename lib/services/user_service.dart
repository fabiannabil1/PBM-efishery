import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/token_storage.dart';

class UserService {
  static final String _baseUrl = Constants.apiUrl;

  Future<User> getCurrentUser() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/profile'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return User(
        name: data['name'],
        phone: data['phone'],
        password: '', // Password is not returned from API
        role: data['role'],
        address: data['address'],
      );
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }

  Future<String> getUserNameById(int id) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/profiles'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      // Cari user dengan id yang sesuai
      final user = data.cast<Map<String, dynamic>>().firstWhere(
        (item) => item['id'] == id,
        orElse: () => {},
      );

      if (user.isNotEmpty) {
        return user['name'];
      } else {
        throw Exception('User with ID $id not found');
      }
    } else {
      throw Exception('Failed to load user profiles: ${response.statusCode}');
    }
  }
}
