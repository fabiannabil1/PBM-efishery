class ProductModel {
  final int? id;
  final String name;
  final String description;
  final double price;
  int stock;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ??'',
      description: json['description'] ??'',
      price: double.parse(json['price'].toString()) ,
      stock: json['stock'] ?? 0,
      imageUrl: json['image_url']??'',
    );
  }
}
