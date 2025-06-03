// services/product_service.dart
import 'package:efishery/models/auction_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../utils/token_storage.dart';

class AuctionService {
  static final String _baseUrl = Constants.apiUrl;

  Future<List<AuctionItem>> fetchAuctions() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/auctions?page=1&per_page=10'),
      headers: {
        // 'Content-Type': 'application/json',
        if (token != null)
          'Authorization': 'Bearer $token', // Tambahkan token jika diperlukan
      },
    );
    // print('Response status: ${response.statusCode}');
    // print('token: $token'); // Debugging untuk melihat token yang digunakan

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => AuctionItem.fromJson(json)).toList();
    } else {
      throw Exception('Gagal Memuat Auction : ${response.statusCode}');
    }
  }

  Future<bool> placeBid(int auctionId, double bidAmount) async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auctions/$auctionId/bids'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'bid_amount': bidAmount}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal melakukan bid: ${response.statusCode}');
    }
  }
}
