import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../utils/token_storage.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class ProdukService {
  static final String _baseUrl = Constants.apiUrl;

  Future<List<Map<String, dynamic>>> getProduk() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/products'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Gagal memuat produk: ${response.statusCode}');
    }
  }

  Future<bool> createProduk({
    required String name,
    required String description,
    required int stock,
    required int price,
    File? image,
  }) async {
    final token = await TokenStorage.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/products'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['stock'] = stock.toString();
    request.fields['price'] = price.toString();

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final response = await request.send();

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal menambahkan produk: ${response.statusCode}');
    }
  }

  Future<bool> updateProdukById({
    required int id,
    required String name,
    required String description,
    required int price,
    File? image,
  }) async {
    final token = await TokenStorage.getToken();
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$_baseUrl/api/products/$id'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal mengupdate produk: ${response.statusCode}');
    }
  }

  Future<bool> updateStokProdukById({
    required int id,
    required int newStock,
  }) async {
    final token = await TokenStorage.getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/api/products/$id/stock'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'stock': newStock}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal mengupdate stok produk: ${response.statusCode}');
    }
  }

  Future<bool> deleteProdukById(int id) async {
    final token = await TokenStorage.getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/products/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Gagal menghapus produk: ${response.statusCode}');
    }
  }
}
