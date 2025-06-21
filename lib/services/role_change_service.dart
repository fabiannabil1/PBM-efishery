import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../utils/token_storage.dart';

class RoleChangeService {
  static final String _baseUrl = Constants.apiUrl;

  Future<Map<String, dynamic>> requestRoleChange(String reason) async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/role-change/request'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'reason': reason}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to request role change: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> checkRequestStatus() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/role-change/status'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return {'status': 'none'};
    } else {
      throw Exception('Failed to check request status: ${response.statusCode}');
    }
  }
}
