class ProductModel {
  final String name;
  final int price;
  // final String weight;
  final String description;
  final int stock;

  ProductModel({
    required this.name,
    required this.price,
    // required this.weight,
    required this.description,
    required this.stock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] is int ? json['price'] : int.tryParse(json['price'].toString()) ?? 0,
      // weight: json['weight'] ?? '',
      stock: json['stock'] is int ? json['stock'] : int.tryParse(json['stock'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
    // 'weight': weight,
    'stock': stock,
  };

}
