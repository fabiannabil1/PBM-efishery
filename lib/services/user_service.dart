import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
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

  Future<Map<String, dynamic>> getFullProfile() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/profile'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch profile: ${response.statusCode}');
    }
  }

  Future<bool> updateUserProfile({
    String? name,
    String? address,
    String? bio,
    File? imageFile,
  }) async {
    final token = await TokenStorage.getToken();
    final uri = Uri.parse('$_baseUrl/api/profile');

    var request = http.MultipartRequest('PUT', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Menambahkan field non-file
    if (name != null) request.fields['name'] = name;
    if (address != null) request.fields['address'] = address;
    if (bio != null) request.fields['bio'] = bio;

    // Menambahkan file jika ada
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    // Kirim request
    final response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      final respStr = await response.stream.bytesToString();
      print('Update failed: ${response.statusCode} | $respStr');
      return false;
    }
  }
}
