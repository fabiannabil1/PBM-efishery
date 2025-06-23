import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/orders.dart';
import '../models/order_item.dart';
import '../utils/constants.dart';
import '../utils/token_storage.dart';

class OrderService {
  static const String baseUrl = Constants.apiUrl;

  // Ambil headers dengan token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Validasi order sebelum dikirim ke API
  static void validateOrder(OrderModel order) {
    if (order.items.isEmpty) {
      throw Exception('Order harus memiliki minimal satu produk');
    }
    for (var item in order.items) {
      if (item.productName.isEmpty) throw Exception('Nama produk tidak boleh kosong');
      if (item.quantity <= 0) throw Exception('Jumlah produk tidak valid');
      if (item.unitPrice <= 0) throw Exception('Harga produk tidak valid');
    }
    if (order.totalPrice <= 0) {
      throw Exception('Total harga tidak valid');
    }
  }

  // Membuat order baru
  static Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final headers = await _getHeaders();

      final itemsPayload = order.items.map((item) => {
        'product_id': item.productId,
        'quantity': item.quantity,
      }).toList();

      final body = {
        'items': itemsPayload,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return OrderModel.fromJson(responseData);
      } else {
        throw Exception(responseData['error'] ?? 'Gagal membuat order');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat membuat order: ${e.toString()}');
    }
  }

  // Ambil semua order
  static Future<List<OrderModel>> getAllOrders() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/api/orders'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData is List) {
        return responseData.map<OrderModel>((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data order');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data order: ${e.toString()}');
    }
  }

  // Ambil order by ID
  static Future<OrderModel> getOrderById(int id) async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$id'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData is Map<String, dynamic>) {
        return OrderModel.fromJson(responseData);
      } else if (response.statusCode == 404) {
        throw Exception('Order tidak ditemukan');
      } else {
        throw Exception(responseData['error'] ?? 'Gagal mengambil order');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil order: ${e.toString()}');
    }
  }

  // Update status order
  static Future<OrderModel> updateOrderStatus(int id, String status) async {
    try {
      final headers = await _getHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/api/orders/$id/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData is Map<String, dynamic>) {
        return OrderModel.fromJson(responseData);
      } else if (response.statusCode == 404) {
        throw Exception('Order tidak ditemukan');
      } else {
        throw Exception(responseData['error'] ?? 'Gagal update status order');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat update status: ${e.toString()}');
    }
  }
}
