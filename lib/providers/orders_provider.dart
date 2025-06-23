import 'package:flutter/foundation.dart';
import '../../models/orders.dart';
import '../../services/orders_service.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;
  OrderModel? _selectedOrder;

  // Getters
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  OrderModel? get selectedOrder => _selectedOrder;

  // Statistik
  int get totalOrders => _orders.length;
  double get totalRevenue =>
      _orders.fold(0, (sum, order) => sum + order.totalPrice);
  int get completedOrders => _orders.where((o) => o.status == 'paid').length;
  int get pendingOrders => _orders.where((o) => o.status == 'pending').length;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  Future<void> addOrder(OrderModel order) async {
    try {
      _setLoading(true);
      clearError();

      OrderService.validateOrder(order);

      final created = await OrderService.createOrder(order);

      // Add to local list immediately without extra notifyListeners
      _orders.insert(0, created);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Gagal membuat order: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> fetchOrders() async {
    try {
      _setLoading(true);
      clearError();

      _orders = await OrderService.getAllOrders();

      notifyListeners();
    } catch (e) {
      _setError('Gagal mengambil data order: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchOrderById(int id) async {
    try {
      _setLoading(true);
      clearError();

      final data = await OrderService.getOrderById(id);
      _selectedOrder = data;

      notifyListeners();
    } catch (e) {
      _setError('Gagal mengambil order: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateOrderStatus(int id, String status) async {
    try {
      _setLoading(true);
      clearError();

      final updated = await OrderService.updateOrderStatus(id, status);

      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        _orders[index] = updated;
      }

      if (_selectedOrder?.id == id) {
        _selectedOrder = updated;
      }

      notifyListeners();
    } catch (e) {
      _setError('Gagal update status: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteOrder(int id) async {
    try {
      _setLoading(true);
      clearError();

      _orders.removeWhere((o) => o.id == id);
      if (_selectedOrder?.id == id) _selectedOrder = null;

      notifyListeners();
    } catch (e) {
      _setError('Gagal menghapus order: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Filter & Search
  List<OrderModel> getOrdersByDate(DateTime date) {
    return _orders
        .where(
          (o) =>
              o.orderDate.year == date.year &&
              o.orderDate.month == date.month &&
              o.orderDate.day == date.day,
        )
        .toList();
  }

  List<OrderModel> getOrdersByStatus(String status) =>
      _orders.where((o) => o.status == status).toList();

  List<OrderModel> getOrdersByDateRange(DateTime start, DateTime end) {
    return _orders
        .where(
          (o) =>
              o.orderDate.isAfter(start.subtract(const Duration(days: 1))) &&
              o.orderDate.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  List<OrderModel> searchOrders(String query) {
    if (query.isEmpty) return _orders;
    return _orders
        .where(
          (o) => o.items.any(
            (item) =>
                item.productName.toLowerCase().contains(query.toLowerCase()),
          ),
        )
        .toList();
  }

  List<OrderModel> getOrdersPaginated(int page, int limit) {
    final start = (page - 1) * limit;
    final end = start + limit;
    if (start >= _orders.length) return [];
    return _orders.sublist(start, end > _orders.length ? _orders.length : end);
  }

  void clearOrders() {
    _orders.clear();
    _selectedOrder = null;
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() async => fetchOrders();

  List<OrderModel> getRecentOrders(int limit) {
    final sorted = List<OrderModel>.from(_orders)
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return sorted.take(limit).toList();
  }

  Map<String, dynamic> getOrderStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisMonth = DateTime(now.year, now.month);

    final todayOrders = getOrdersByDate(today);
    final monthOrders =
        _orders
            .where(
              (o) => o.orderDate.isAfter(
                thisMonth.subtract(const Duration(days: 1)),
              ),
            )
            .toList();

    return {
      'total_orders': totalOrders,
      'today_orders': todayOrders.length,
      'month_orders': monthOrders.length,
      'total_revenue': totalRevenue,
      'today_revenue': todayOrders.fold(0.0, (s, o) => s + o.totalPrice),
      'month_revenue': monthOrders.fold(0.0, (s, o) => s + o.totalPrice),
      'completed_orders': completedOrders,
      'pending_orders': pendingOrders,
    };
  }
}
