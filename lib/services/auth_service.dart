import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart'; // Buat file constants.dart untuk URL base

class AuthService {
  static final String _baseUrl = Constants.apiUrl;

  static Future<Map<String, dynamic>> login(
    String phone,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nomor_hp': phone, // Sesuaikan dengan field di backend
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'token': data['access_token']};
      } else {
        return {'success': false, 'message': data['error']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String phone,
    String password,
    String address,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'nomor_hp':phone, // Jika backend pakai "username" sebagai field nomor HP
          'password': password,
          'address': address,
          'role': 'biasa', // Jika ada field alamat, sesuaikan dengan backend
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }
}
