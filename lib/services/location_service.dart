import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/token_storage.dart';

class LocationService {
  final String baseUrl = Constants.apiUrl;

  Future<int?> saveLocation({
    required String name,
    required double latitude,
    required double longitude,
    required String detailAddress,
  }) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          // 'name': name,
          'latitude': latitude,
          'longitude': longitude,
          // 'detail_address': detailAddress,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data']['id'] as int;
      } else {
        throw Exception('Gagal menyimpan lokasi: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saving location: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLocations() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/locations'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Gagal mengambil data lokasi: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting locations: $e');
    }
  }

  Future<Map<String, dynamic>?> getLocationById(int id) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/location/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
