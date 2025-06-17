class OrderModel {
  final int? id;
  final String productName;
  final int quantity;
  final double price;
  final double totalPrice;
  final double paymentAmount;
  final double change;
  final DateTime orderDate;
  final String status;
  final String? productImage;
  final int productId;

  OrderModel({
    this.id,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.paymentAmount,
    required this.change,
    required this.orderDate,
    this.status = 'completed',
    this.productImage,
    required this.productId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      paymentAmount: (json['payment_amount'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      orderDate: DateTime.parse(json['order_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'completed',
      productImage: json['product_image'],
      productId: json['product_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'total_price': totalPrice,
      'payment_amount': paymentAmount,
      'change': change,
      'order_date': orderDate.toIso8601String(),
      'status': status,
      'product_image': productImage,
      'product_id': productId,
    };
  }

  OrderModel copyWith({
    int? id,
    String? productName,
    int? quantity,
    double? price,
    double? totalPrice,
    double? paymentAmount,
    double? change,
    DateTime? orderDate,
    String? status,
    String? productImage,
    int? productId,
  }) {
    return OrderModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      change: change ?? this.change,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      productImage: productImage ?? this.productImage,
      productId: productId ?? this.productId,
    );
  }
}