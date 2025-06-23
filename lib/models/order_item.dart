class OrderItem {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {}; // nested product

    return OrderItem(
      productId: product['id'] ?? json['product_id'] ?? 0,
      productName: product['name'] ?? json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice:
          double.tryParse(product['price']?.toString() ?? '0') ??
          double.tryParse(json['unit_price']?.toString() ?? '0') ??
          0.0,
      imageUrl: product['image_url'] ?? json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'image_url': imageUrl,
    };
  }

  @override
  String toString() {
    return 'OrderItem(productId: $productId, name: $productName, qty: $quantity, price: $unitPrice)';
  }
}
