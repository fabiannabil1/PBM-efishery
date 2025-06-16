import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/fish_detection_model.dart';
import '../utils/constants.dart';
import '../utils/token_storage.dart';

class FishDetectionService {
  final String baseUrl = Constants.apiUrl;

  Future<FishDetectionResponse> detectFish(File imageFile) async {
    try {
      // Get JWT token
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/detect'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add the image file to the request
      var imageStream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'image',
        imageStream,
        length,
        filename: 'image.jpg',
      );
      request.files.add(multipartFile);

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return FishDetectionResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to detect fish: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during fish detection: $e');
    }
  }
}
