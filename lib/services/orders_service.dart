import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/orders.dart';
import '../models/order_item.dart';
import '../utils/constants.dart';
import '../utils/token_storage.dart';

class OrderService {
  static const String baseUrl = Constants.apiUrl;
  static const Duration _timeout = Duration(seconds: 10);

  // Ambil headers dengan token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method untuk handle HTTP requests dengan timeout
  static Future<http.Response> _makeRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(_timeout);
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda.');
    } on HttpException {
      throw Exception('Server tidak dapat dijangkau.');
    } on FormatException {
      throw Exception('Response dari server tidak valid.');
    } on TimeoutException {
      throw Exception(
        'Request timeout. Server membutuhkan waktu terlalu lama.',
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Validasi order sebelum dikirim ke API
  static void validateOrder(OrderModel order) {
    if (order.items.isEmpty) {
      throw Exception('Order harus memiliki minimal satu produk');
    }
    for (var item in order.items) {
      if (item.productName.isEmpty)
        throw Exception('Nama produk tidak boleh kosong');
      if (item.quantity <= 0) throw Exception('Jumlah produk tidak valid');
      if (item.unitPrice <= 0) throw Exception('Harga produk tidak valid');
    }
    if (order.totalPrice <= 0) {
      throw Exception('Total harga tidak valid');
    }
  }

  // Membuat order baru dengan timeout dan better error handling
  static Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final headers = await _getHeaders();

      final itemsPayload =
          order.items
              .map(
                (item) => {
                  'product_id': item.productId,
                  'quantity': item.quantity,
                },
              )
              .toList();

      final body = {
        'items': itemsPayload,
        'total_price': order.totalPrice,
        'payment_amount': order.paymentAmount,
      };

      final response = await _makeRequest(
        () => http.post(
          Uri.parse('$baseUrl/api/orders'),
          headers: headers,
          body: jsonEncode(body),
        ),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return OrderModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Gagal membuat order');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat membuat order: ${e.toString()}');
    }
  }

  // Ambil semua order dengan timeout
  static Future<List<OrderModel>> getAllOrders() async {
    try {
      final headers = await _getHeaders();

      final response = await _makeRequest(
        () => http.get(Uri.parse('$baseUrl/api/orders'), headers: headers),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is List) {
          return responseData
              .map<OrderModel>((json) => OrderModel.fromJson(json))
              .toList();
        }
        throw Exception('Format response tidak valid');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Gagal mengambil data order');
      }
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan saat mengambil data order: ${e.toString()}',
      );
    }
  }

  // Ambil order by ID dengan timeout
  static Future<OrderModel> getOrderById(int id) async {
    try {
      final headers = await _getHeaders();

      final response = await _makeRequest(
        () => http.get(Uri.parse('$baseUrl/api/orders/$id'), headers: headers),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic>) {
          return OrderModel.fromJson(responseData);
        }
        throw Exception('Format response tidak valid');
      } else if (response.statusCode == 404) {
        throw Exception('Order tidak ditemukan');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Gagal mengambil order');
      }
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan saat mengambil order: ${e.toString()}',
      );
    }
  }

  // Update status order dengan timeout
  static Future<OrderModel> updateOrderStatus(int id, String status) async {
    try {
      final headers = await _getHeaders();

      final response = await _makeRequest(
        () => http.put(
          Uri.parse('$baseUrl/api/orders/$id/status'),
          headers: headers,
          body: jsonEncode({'status': status}),
        ),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic>) {
          return OrderModel.fromJson(responseData);
        }
        throw Exception('Format response tidak valid');
      } else if (response.statusCode == 404) {
        throw Exception('Order tidak ditemukan');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Gagal update status order');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat update status: ${e.toString()}');
    }
  }
}
