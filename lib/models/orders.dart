// models/order.dart
class OrderModel {
  final int? id;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double paymentAmount;
  final double change;
  final DateTime orderDate;
  final String status;
  final String? imageUrl;

  OrderModel({
    this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.paymentAmount,
    required this.change,
    required this.orderDate,
    this.status = 'completed',
    this.imageUrl,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      paymentAmount: (json['payment_amount'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      orderDate: DateTime.parse(json['order_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'completed',
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'payment_amount': paymentAmount,
      'change': change,
      'order_date': orderDate.toIso8601String(),
      'status': status,
      'image_url': imageUrl,
    };
  }
}