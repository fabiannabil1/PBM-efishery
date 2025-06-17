// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import 'orders_screen.dart'; // Import the orders screen

class DetailProdukScreen extends StatefulWidget {
  final ProductModel product;

  const DetailProdukScreen({super.key, required this.product});

  @override
  State<DetailProdukScreen> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProdukScreen> {
  int quantity = 1;
  bool isFavorite = false;
  final TextEditingController _paymentController = TextEditingController();

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final String productName = widget.product.name;
    final double price = widget.product.price.toDouble();
    final String description = widget.product.description;
    final String? imageUrl = widget.product.imageUrl;

    // Truncate name for app bar
    final String truncatedName = productName.length > 20
        ? '${productName.substring(0, 20)}...'
        : productName;

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Scaffold(
          appBar: CustomAppBar(title: truncatedName, showBackButton: true),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section with Hero Animation
                Hero(
                  tag: 'product_image_${widget.product.id}',
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 300,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 300,
                                color: Colors.grey[200],
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Gambar tidak dapat dimuat',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              height: 300,
                              color: Colors.grey[200],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tidak ada gambar',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),

                // Content Section
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Favorite Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              productName,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFavorite 
                                        ? 'Ditambahkan ke favorit' 
                                        : 'Dihapus dari favorit',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.product.stock > 0 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.product.stock > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Text(
                          widget.product.stock > 0 ? 'Tersedia (${widget.product.stock})' : 'Stok Habis',
                          style: TextStyle(
                            color: widget.product.stock > 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Price Card
                      _buildInfoCard(
                        context,
                        icon: Icons.monetization_on,
                        title: 'Harga',
                        value: currencyFormat.format(price),
                        iconColor: Colors.green,
                        valueStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Stock Card
                      _buildInfoCard(
                        context,
                        icon: Icons.inventory,
                        title: 'Stok Tersedia',
                        value: '${widget.product.stock} item',
                        iconColor: Colors.blue,
                      ),
                      const SizedBox(height: 12),

                      // Description Section
                      Text(
                        'Deskripsi Produk',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          description.isNotEmpty 
                              ? description 
                              : 'Produk ikan segar berkualitas tinggi dengan rasa yang lezat dan bergizi. Cocok untuk berbagai jenis masakan dan memiliki tekstur daging yang kenyal.',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Quantity Section - only show if stock is available
                      if (widget.product.stock > 0) ...[
                        Text(
                          'Jumlah',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.shopping_cart, color: Colors.blue),
                              const SizedBox(width: 12),
                              const Text(
                                'Jumlah pesanan:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: quantity > 1
                                          ? () {
                                              setState(() {
                                                quantity--;
                                              });
                                            }
                                          : null,
                                      icon: const Icon(Icons.remove),
                                      iconSize: 20,
                                      constraints: const BoxConstraints(
                                        minWidth: 36,
                                        minHeight: 36,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        quantity.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: quantity < widget.product.stock
                                          ? () {
                                              setState(() {
                                                quantity++;
                                              });
                                            }
                                          : null,
                                      icon: const Icon(Icons.add),
                                      iconSize: 20,
                                      constraints: const BoxConstraints(
                                        minWidth: 36,
                                        minHeight: 36,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Total Price
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Harga:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                currencyFormat.format(price * quantity),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Action Buttons
                      if (widget.product.stock > 0) ...[
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: productProvider.isLoading 
                                    ? null 
                                    : () {
                                        _showPurchaseDialog(context, productName, price * quantity);
                                      },
                                icon: productProvider.isLoading 
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.shopping_cart, color: Colors.white,),
                                label: Text(productProvider.isLoading ? 'Memproses...' : 'Beli Sekarang'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        // Out of stock message
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Produk sedang tidak tersedia',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                                            
                      // Show error if exists
                      if (productProvider.error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  productProvider.error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  productProvider.clearError();
                                },
                                child: const Text('Tutup'),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 64),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    TextStyle? valueStyle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: valueStyle ??
                      const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, String productName, double totalPrice) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // Reset payment controller
    _paymentController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            return StatefulBuilder(
              builder: (context, setState) {
                double paymentAmount = 0;
                if (_paymentController.text.isNotEmpty) {
                  paymentAmount = double.tryParse(_paymentController.text.replaceAll('.', '')) ?? 0;
                }
                
                double change = paymentAmount - totalPrice;
                bool isPaymentSufficient = paymentAmount >= totalPrice;

                return AlertDialog(
                  title: Row(
                    children: [
                      const Icon(Icons.payment, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Konfirmasi Pembayaran')),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        iconSize: 20,
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Summary
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Detail Pesanan:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Produk: $productName'),
                              Text('Jumlah: $quantity item'),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Bayar:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    currencyFormat.format(totalPrice),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Payment Input
                        const Text(
                          'Masukkan Jumlah Uang:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _paymentController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _CurrencyInputFormatter(),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Masukkan jumlah uang...',
                            prefixText: 'Rp ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue[400]!),
                            ),
                            suffixIcon: paymentAmount > 0
                                ? Icon(
                                    isPaymentSufficient ? Icons.check_circle : Icons.error,
                                    color: isPaymentSufficient ? Colors.green : Colors.red,
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 12),

                        // Payment Status
                        if (paymentAmount > 0) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isPaymentSufficient 
                                  ? Colors.green[50] 
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isPaymentSufficient 
                                    ? Colors.green[200]! 
                                    : Colors.red[200]!,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isPaymentSufficient 
                                          ? Icons.check_circle 
                                          : Icons.warning,
                                      color: isPaymentSufficient 
                                          ? Colors.green[700] 
                                          : Colors.red[700],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isPaymentSufficient 
                                          ? 'Pembayaran Valid' 
                                          : 'Uang Tidak Cukup',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isPaymentSufficient 
                                            ? Colors.green[700] 
                                            : Colors.red[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (isPaymentSufficient) ...[
                                  if (change > 0) ...[
                                    Text(
                                      'Kembalian: ${currencyFormat.format(change)}',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      'Uang pas! Tidak ada kembalian.',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ] else ...[
                                  Text(
                                    'Kurang: ${currencyFormat.format(-change)}',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: productProvider.isLoading 
                          ? null 
                          : () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: productProvider.isLoading || !isPaymentSufficient
                          ? null 
                          : () async {
                              Navigator.of(context).pop();
                              
                              // Simulate purchase process
                              try {
                                // Update stock after purchase
                                final newStock = widget.product.stock - quantity;
                                final success = await productProvider.updateProductStock(
                                  id: widget.product.id!,
                                  newStock: newStock,
                                );
                                
                                if (success) {
                                  // Show success message with change info
                                  String successMessage = 'Pembelian berhasil! Pesanan sedang diproses.';
                                  if (change > 0) {
                                    successMessage += '\nKembalian: ${currencyFormat.format(change)}';
                                  }
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(successMessage),
                                      duration: const Duration(seconds: 4),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  
                                  // Update local product data
                                  setState(() {
                                    widget.product.stock = newStock;
                                    quantity = 1; // Reset quantity
                                  });

                                  // Navigate to orders page
                                  _showOrderSuccessDialog(context, change);
                                  
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pembelian gagal. Silakan coba lagi.'),
                                      duration: Duration(seconds: 3),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPaymentSufficient ? null : Colors.grey,
                      ),
                      child: productProvider.isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Bayar'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showOrderSuccessDialog(BuildContext context, double change) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 28),
              const SizedBox(width: 8),
              const Text('Pembayaran Berhasil!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Transaksi Anda telah berhasil diproses.'),
              if (change > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kembalian: ${currencyFormat.format(change)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to orders page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrdersScreen(),
                  ),
                );
              },
              child: const Text('Lihat Pesanan'),
            ),
          ],
        );
      },
    );
  }
}

// Currency Input Formatter
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove any non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Format with thousand separators
    final formatter = NumberFormat('#,##0', 'id_ID');
    String formatted = formatter.format(int.parse(digitsOnly));
    
    // Replace commas with dots for Indonesian format
    formatted = formatted.replaceAll(',', '.');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}