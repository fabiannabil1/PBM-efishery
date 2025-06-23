import 'order_item.dart';

class OrderModel {
  final int? id;
  final List<OrderItem> items;
  final double totalPrice;
  final double paymentAmount;
  final double change;
  final DateTime orderDate;
  final String status;

  OrderModel({
    this.id,
    required this.items,
    required this.totalPrice,
    required this.paymentAmount,
    required this.change,
    required this.orderDate,
    required this.status,
  });

  /// Getter untuk jumlah total item
  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + (item.quantity ?? 0));

  /// Factory constructor from JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return OrderModel(
      id: json['id'],
      items: rawItems is List
          ? rawItems.map((item) => OrderItem.fromJson(item)).toList()
          : [],
      totalPrice:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      paymentAmount:
          double.tryParse(json['payment_amount']?.toString() ?? '0') ?? 0.0,
      change: double.tryParse(json['change']?.toString() ?? '0') ?? 0.0,
      orderDate:
          DateTime.tryParse(json['order_date']?.toString() ?? '') ??
              DateTime.now(),
      status: json['status'] ?? 'pending',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalPrice,
      'payment_amount': paymentAmount,
      'change': change,
      'order_date': orderDate.toIso8601String(),
      'status': status,
    };
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, totalPrice: $totalPrice, status: $status, items: $items)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is OrderModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
