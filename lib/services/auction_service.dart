// services/product_service.dart
import '../../models/auction_item.dart';
import '../../models/bid_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../utils/token_storage.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class AuctionService {
  static final String _baseUrl = Constants.apiUrl;

  Future<List<AuctionItem>> fetchAuctions() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/auctions?page=1&per_page=20'),
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

  Future<List<AuctionItem>> fetchMyAuctions() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/auctions/current?page=1&per_page=20'),
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
      throw Exception('Gagal Memuat Item Lelangmu : ${response.statusCode}');
    }
  }

  Future<bool> placeBid(int auctionId, double bidAmount) async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auctions/$auctionId/bid'),
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

  Future<bool> placeAuctionItem(int auctionId, double bidAmount) async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auctions/$auctionId/bid'),
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

  Future<bool> createAuction({
    required String title,
    required String description,
    required int locationId,
    required double startingPrice,
    required String deadline,
    required File image,
  }) async {
    final token = await TokenStorage.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/auctions'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['location_id'] = locationId.toString();
    request.fields['starting_price'] = startingPrice.toString();
    request.fields['deadline'] = deadline;

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType(
          'image',
          'png',
        ), // kamu bisa ubah sesuai mimetype
      ),
    );

    final response = await request.send();

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal menambahkan lelang: ${response.statusCode}');
    }
  }

  Future<bool> updateAuction({
    required int auctionId,
    required String title,
    required String description,
    required double startingPrice,
    required DateTime deadline,
    required int locationId,
  }) async {
    final token = await TokenStorage.getToken();

    final url = Uri.parse('$_baseUrl/api/auctions/$auctionId');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'starting_price': startingPrice,
        'deadline': deadline.toIso8601String(), // Format ISO 8601
        'location_id': locationId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 403) {
      throw Exception('Tidak diizinkan mengubah auction.');
    } else if (response.statusCode == 404) {
      throw Exception('Auction tidak ditemukan.');
    } else {
      throw Exception(
        'Gagal update auction: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<bool> deleteAuction(int auctionId) async {
    final token = await TokenStorage.getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/auctions/$auctionId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 403) {
      throw Exception('Tidak diizinkan menghapus auction.');
    } else if (response.statusCode == 404) {
      throw Exception('Auction tidak ditemukan.');
    } else {
      throw Exception(
        'Gagal menghapus auction: ${response.statusCode} ${response.body}',
      );
    }
  }

  //ini untuk mendapatkan bid dari auction tertentu
  Future<List<BidItem>> fetchBidsForAuction(int auctionId) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/auctions/$auctionId/bids'),
      headers: {
        'accept': '*/*',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => BidItem.fromJson(json)).toList();
    } else {
      throw Exception(
        'Gagal Memuat Bid untuk Lelang ID $auctionId: ${response.statusCode}',
      );
    }
  }

  // Close auction and get winner info
  Future<Map<String, dynamic>> closeAuction(int auctionId) async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auctions/$auctionId/close'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'message': data['message'],
        'winner_id': data['winner_id'],
      };
    } else if (response.statusCode == 403) {
      throw Exception('Tidak diizinkan menutup auction.');
    } else if (response.statusCode == 404) {
      throw Exception('Auction tidak ditemukan.');
    } else {
      throw Exception(
        'Gagal menutup auction: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Get highest bid for auction
  Future<Map<String, dynamic>?> getHighestBid(int auctionId) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/auctions/$auctionId/highest_bid'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('message')) {
        // No bids yet
        return null;
      }
      return data;
    } else {
      throw Exception(
        'Gagal mendapatkan bid tertinggi: ${response.statusCode}',
      );
    }
  }
}
