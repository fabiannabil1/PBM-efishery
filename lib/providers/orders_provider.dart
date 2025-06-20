// providers/order_provider.dart
import 'package:flutter/material.dart';
import '../models/orders.dart';
import '../services/orders_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // List<OrderModel> get orders => _orders;

  void addOrder(OrderModel order) {
    _orders.add(order);
    notifyListeners();
  }

  // Jika ingin fitur tambahan:
  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  // Get orders sorted by date (newest first)
  List<OrderModel> get sortedOrders {
    final sorted = List<OrderModel>.from(_orders);
    sorted.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return sorted;
  }

  Future<void> fetchOrders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _orders = await _orderService.fetchOrders();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder(OrderModel order) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _orderService.createOrder(order);

      if (result) {
        // Add order to local list without fetching all orders again
        _orders.add(order);
        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<OrderModel?> getOrderById(int id) async {
    try {
      return await _orderService.getOrderById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateOrderStatus(int id, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _orderService.updateOrderStatus(id, status);

      if (result) {
        // Update local order status
        final orderIndex = _orders.indexWhere((order) => order.id == id);
        if (orderIndex != -1) {
          _orders[orderIndex] = OrderModel(
            id: _orders[orderIndex].id,
            productName: _orders[orderIndex].productName,
            quantity: _orders[orderIndex].quantity,
            unitPrice: _orders[orderIndex].unitPrice,
            totalPrice: _orders[orderIndex].totalPrice,
            paymentAmount: _orders[orderIndex].paymentAmount,
            change: _orders[orderIndex].change,
            orderDate: _orders[orderIndex].orderDate,
            status: status,
            imageUrl: _orders[orderIndex].imageUrl,
          );
        }
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get total revenue from completed orders
  double get totalRevenue {
    return _orders
        .where((order) => order.status == 'completed')
        .fold(0.0, (sum, order) => sum + order.totalPrice);
  }

  // Get total orders count
  int get totalOrdersCount => _orders.length;

  // Get orders by status
  List<OrderModel> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }
}
