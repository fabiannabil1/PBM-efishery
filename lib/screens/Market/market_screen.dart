// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../widgets/custom_appbar.dart';
import '../../widgets/navbar.dart';
// import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/productcard.dart';
// import 'package:intl/intl.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.fetchProducts();
      searchController.addListener(() {
        provider.filterProducts(searchController.text);
      });
    });
  }

  Future<void> _onRefresh() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    await provider.fetchProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      // appBar: const CustomAppBar(title: 'Market', showBackButton: false),
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 39),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0F4C75),
                        Color(0xFF3282B8),
                        Color(0xFF0F4C75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3282B8).withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Color(0xFFFFE66D),
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Belanja!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Temukan produk budidaya perikanan terbaik di sini.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.set_meal_outlined,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF1E88E5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3282B8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        size: 20,
                        color: Color(0xFF3282B8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Produk',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F4C75),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 0),
                productProvider.filteredProducts.isEmpty &&
                        searchController.text.isNotEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Produk tidak ditemukan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Coba kata kunci lain',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3 / (5 * 0.9),
                            crossAxisSpacing: 8, // reduced from 16
                            mainAxisSpacing: 16, // reduced from 32
                          ),
                      itemCount: productProvider.filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = productProvider.filteredProducts[index];
                        return ProductCard(product: product);
                      },
                    ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/auctions/menu');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/cart_page');
        },
        backgroundColor: const Color(0xFF1E88E5),
        child: Stack(
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            // Badge notifikasi
            // Positioned(
            //   right: 0,
            //   top: 0,
            //   child: Container(
            //     padding: const EdgeInsets.all(2),
            //     decoration: BoxDecoration(
            //       color: Colors.red,
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
            //     child: const Text(
            //       '2',
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 8,
            //         fontWeight: FontWeight.bold,
            //       ),
            //       textAlign: TextAlign.center,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  //   Widget _buildProductCard(
  //     String name,
  //     String price,
  //     String imagePath,
  //     String description,
  //   ) {
  //     return GestureDetector(
  //       onTap: () {
  //         Navigator.pushNamed(
  //           context,
  //           '/productdetails_page',
  //           arguments: {
  //             'name': name,
  //             'price':
  //                 double.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0,
  //             'image': imagePath,
  //             'description': description,
  //           },
  //         );
  //       },
  //       child: Hero(
  //         tag: 'product_image_$name',
  //         child: Container(
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(12),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.grey.withOpacity(0.1),
  //                 spreadRadius: 1,
  //                 blurRadius: 5,
  //                 offset: const Offset(0, 2),
  //               ),
  //             ],
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Expanded(
  //                 flex: 3,
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     borderRadius: const BorderRadius.vertical(
  //                       top: Radius.circular(12),
  //                     ),
  //                     image: DecorationImage(
  //                       image: AssetImage(imagePath),
  //                       fit: BoxFit.cover,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 2,
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         name,
  //                         style: const TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 14,
  //                         ),
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                       Text(
  //                         description,
  //                         style: TextStyle(color: Colors.grey[600], fontSize: 10),
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                       Text(
  //                         price,
  //                         style: const TextStyle(
  //                           color: Colors.blue,
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 12,
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         width: double.infinity,
  //                         child: ElevatedButton(
  //                           onPressed: () {
  //                             ScaffoldMessenger.of(context).showSnackBar(
  //                               SnackBar(
  //                                 content: Text('$name ditambahkan ke keranjang'),
  //                               ),
  //                             );
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.blue,
  //                             padding: const EdgeInsets.symmetric(vertical: 4),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(8),
  //                             ),
  //                           ),
  //                           child: const Text(
  //                             'Beli',
  //                             style: TextStyle(fontSize: 12, color: Colors.white),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   String _formatPrice(dynamic price) {
  //     try {
  //       return NumberFormat(
  //         '#,##0',
  //         'id_ID',
  //       ).format(double.tryParse(price.toString()) ?? 0);
  //     } catch (_) {
  //       return '0';
  //     }
  //   }
}
