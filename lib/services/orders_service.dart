import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/orders.dart';

class OrderService {
  static const String baseUrl = 'http://efishery.acerkecil.my.id/api';

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
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

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

  Future<OrderModel?> fetchOrderById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OrderModel.fromJson(data);
      } else {
        print('Failed to fetch order. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching order: $e');
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

  Future<bool> deleteOrder(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/orders/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to delete order. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting order: $e');
      return false;
    }
  }
}