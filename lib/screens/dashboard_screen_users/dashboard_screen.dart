import 'package:efishery/screens/dashboard_screen_users/cart_screen/cart_screen.dart';
import 'package:flutter/material.dart';
import '../../../models/product.dart';
import 'product_screen/product_detail_screen.dart'; // Import halaman detail produk

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  // Dummy data - nanti bisa diganti dengan API call
  final List<ProductModel> dummyProducts = [
    ProductModel(
      name: "Pakan Ikan",
      description: "Pakan berkualitas untuk ikan lele.",
      price: 50000,
      weight: "1kg",
      stock: 10,
    ),
    ProductModel(
      name: "Pompa Air",
      description: "Pompa air hemat energi.",
      price: 250000,
      weight: "2kg",
      stock: 5,
    ),
    ProductModel(
      name: "Vitamin Ikan",
      description: "Menambah daya tahan tubuh ikan.",
      price: 35000,
      weight: "250g",
      stock: 15,
    ),
    ProductModel(
      name: "Jaring Kolam",
      description: "Jaring kuat dan tahan lama.",
      price: 150000,
      weight: "1.5kg",
      stock: 8,
    ),
    ProductModel(
      name: "Obat Anti Jamur",
      description: "Mengatasi jamur pada ikan.",
      price: 40000,
      weight: "100ml",
      stock: 12,
    ),
    ProductModel(
      name: "Termometer Air",
      description: "Memonitor suhu air kolam.",
      price: 75000,
      weight: "150g",
      stock: 20,
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadProducts();
    searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Method untuk load products - bisa diganti dengan API call
  Future<void> loadProducts() async {
    setState(() {
      isLoading = true;
    });

    // Simulasi loading dari API
    await Future.delayed(Duration(milliseconds: 500));
    
    // TODO: Ganti dengan API call
    // final response = await ApiService.getProducts();
    // products = response.data;
    
    setState(() {
      products = dummyProducts;
      filteredProducts = products;
      isLoading = false;
    });
  }

  // Method untuk filter products berdasarkan search
  void _filterProducts() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products.where((product) {
        return product.name.toLowerCase().contains(query) ||
               product.description.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Method untuk navigasi ke halaman detail produk
  void _navigateToProductDetail(ProductModel product) {
    // Menggunakan Navigator.push untuk navigasi langsung
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
    
    // Atau jika menggunakan named routes:
    // Navigator.pushNamed(
    //   context,
    //   '/product-detail',
    //   arguments: product,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartScreen()),
          );
        },
        child: Icon(Icons.shopping_basket, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              color: Colors.grey[300],
              width: double.infinity,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selamat Datang', style: TextStyle(fontSize: 18)),
                  Text(
                    'di E-Fishery',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 10),
            
            // Banner Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.lightBlue[300],
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '8 Peralatan Yang Dibutuhkan Dalam Budidaya Ikan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            SizedBox(height: 10),
            
            // Categories Section
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildCategory('Toko Budidaya'),
                  _buildCategory('Efeeder'),
                  _buildCategory('Obat dan Vitamin'),
                  _buildCategory('Paket'),
                ],
              ),
            ),
            
            // Search Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
            
            // Products Grid Section
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Produk tidak ditemukan',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(12),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3 / 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            return ProductItem(
                              product: filteredProducts[index],
                              onTap: () => _navigateToProductDetail(filteredProducts[index]),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String name) {
    return Container(
      width: 100,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, size: 24, color: Colors.grey[600]),
          SizedBox(height: 4),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// Widget untuk menampilkan item produk dengan navigasi
class ProductItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductItem({
    super.key, 
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Placeholder
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                      ),
                      // Badge stok
                      if (product.stock <= 5)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: product.stock == 0 ? Colors.red : Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              product.stock == 0 ? 'Habis' : 'Sisa ${product.stock}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Product Details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        product.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Rp ${_formatPrice(product.price)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 2),
                              Text(
                                '${product.stock}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}