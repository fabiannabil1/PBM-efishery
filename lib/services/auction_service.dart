// services/product_service.dart
import 'package:efishery/models/auction_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class AuctionService {
  static final String _baseUrl = Constants.apiUrl;

  Future<List<AuctionItem>> fetchAuctions() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/auctions'));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => AuctionItem.fromJson(json)).toList();
    } else {
      throw Exception('Gagal Memuat Auction : ${response.statusCode}');
    }
  }
}
