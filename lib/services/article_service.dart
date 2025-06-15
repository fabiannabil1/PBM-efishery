import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../utils/token_storage.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class ArticleService {
  static final String _baseUrl = Constants.apiUrl;

  Future<List<Map<String, dynamic>>> fetchArticles() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/articles?page=1&per_page=10'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Gagal Memuat Artikel: ${response.statusCode}');
    }
  }

  Future<bool> createArticle({
    required String title,
    required String content,
    File? image,
  }) async {
    final token = await TokenStorage.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/articles'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.fields['content'] = content;

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
      throw Exception('Gagal menambahkan artikel: ${response.statusCode}');
    }
  }

  Future<bool> updateArticle({
    required int articleId,
    required String title,
    required String content,
    File? image,
  }) async {
    final token = await TokenStorage.getToken();
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$_baseUrl/api/articles/$articleId'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.fields['content'] = content;

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
      throw Exception('Gagal mengupdate artikel: ${response.statusCode}');
    }
  }

  Future<bool> deleteArticle(int articleId) async {
    final token = await TokenStorage.getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/articles/$articleId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Gagal menghapus artikel: ${response.statusCode}');
    }
  }
}
