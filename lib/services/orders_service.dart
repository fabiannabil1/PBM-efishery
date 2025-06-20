// services/order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/orders.dart';

class OrderService {
  static const String baseUrl = 'http://efishery.acerkecil.my.id';

  Future<bool> createOrder(OrderModel order) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(order.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create order. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  Future<List<OrderModel>> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('http://efishery.acerkecil.my.id/api/orders'));


      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => OrderModel.fromJson(item)).toList();
      } else {
        print('Failed to fetch orders. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<OrderModel?> getOrderById(int id) async {
    try {
      final response = await http.get(Uri.parse('http://efishery.acerkecil.my.id/api/orders'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return OrderModel.fromJson(data);
      } else {
        print('Failed to get order. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  Future<bool> updateOrderStatus(int id, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update order status. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }
}