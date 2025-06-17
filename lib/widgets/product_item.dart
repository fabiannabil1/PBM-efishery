// import 'package:flutter/material.dart';
// import '../models/product.dart';
// import '../screens/dashboard_screen_users/product_screen/product_detail_screen.dart';

// class ProductItem extends StatelessWidget {
//   final ProductModel product;

//   const ProductItem({super.key, required this.product});
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ProductDetailPage(product: product),
//           ),
//         );
//       },
//       child: Column(
//         children: [
//           Container(
//             height: 60,
//             width: 60,
//             color: Colors.grey[300],
//           ),
//           SizedBox(height: 8),
//           Text('Rp ${product.price}'),
//           Text(product.name),
//           Text(product.weight),
//         ],
//       ),
//     );
//   }
// }