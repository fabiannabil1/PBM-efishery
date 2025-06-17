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

  // Get orders sorted by date (newest first)
  List<OrderModel> get sortedOrders {
    final sorted = List<OrderModel>.from(_orders);
    sorted.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return sorted;
  }

  // Get orders by status
  List<OrderModel> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get total orders count
  int get totalOrders => _orders.length;

  // Get total revenue
  double get totalRevenue {
    return _orders.fold(0.0, (sum, order) => sum + order.totalPrice);
  }

  Future<bool> createOrder(OrderModel order) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _orderService.createOrder(order);
      
      if (success) {
        // Add to local list immediately for better UX
        _orders.add(order.copyWith(
          id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
        ));
        // Fetch latest data from server
        await fetchOrders();
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchOrders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final orders = await _orderService.fetchOrders();
      _orders = orders;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> fetchOrderById(int id) async {
    try {
      _error = null;
      notifyListeners();

      final order = await _orderService.fetchOrderById(id);
      return order;
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

      final success = await _orderService.updateOrderStatus(id, status);
      
      if (success) {
        // Update local data
        final index = _orders.indexWhere((order) => order.id == id);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(status: status);
        }
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteOrder(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _orderService.deleteOrder(id);
      
      if (success) {
        _orders.removeWhere((order) => order.id == id);
      }

      _isLoading = false;
      notifyListeners();
      return success;
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

  // Filter orders by date range
  List<OrderModel> getOrdersByDateRange(DateTime startDate, DateTime endDate) {
    return _orders.where((order) {
      return order.orderDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             order.orderDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Get orders for today
  List<OrderModel> get todayOrders {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    return getOrdersByDateRange(startOfDay, endOfDay);
  }

  // Get orders for this month
  List<OrderModel> get thisMonthOrders {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return getOrdersByDateRange(startOfMonth, endOfMonth);
  }
}