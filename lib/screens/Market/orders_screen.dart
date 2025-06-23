// screens/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/orders_provider.dart';
import '../../models/orders.dart';
import '../../widgets/custom_appbar.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch orders when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Riwayat Pesanan',
        showBackButton: true,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat pesanan...'),
                ],
              ),
            );
          }

          if (orderProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    orderProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      orderProvider.clearError();
                      orderProvider.fetchOrders();
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final orders = orderProvider.orders;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pesanan',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pesanan Anda akan muncul di sini',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Mulai Belanja'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderProvider.refresh(),
            child: Column(
              children: [
                // Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.blue[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem(
                          'Total Pesanan',
                          orderProvider.totalOrders.toString(),
                          Icons.shopping_bag,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      Expanded(
                        child: _buildSummaryItem(
                          'Total Pengeluaran',
                          currencyFormat.format(orderProvider.totalRevenue),
                          Icons.monetization_on,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter Tabs (Optional)
                // Container(
                //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: _buildFilterChip(
                //           'Semua (${orderProvider.totalOrders})',
                //           true,
                //           () {},
                //         ),
                //       ),
                //       const SizedBox(width: 8),
                //       Expanded(
                //         child: _buildFilterChip(
                //           'Selesai (${orderProvider.completedOrders})',
                //           false,
                //           () {},
                //         ),
                //       ),
                //       const SizedBox(width: 8),
                //       Expanded(
                //         child: _buildFilterChip(
                //           'Pending (${orderProvider.pendingOrders})',
                //           false,
                //           () {},
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                // Orders List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(
                        context,
                        order,
                        currencyFormat,
                        orderProvider,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderModel order,
    NumberFormat currencyFormat,
    OrderProvider orderProvider,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOrderDetails(context, order, orderProvider),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        order.items.isNotEmpty &&
                                order.items.first.imageUrl != null &&
                                order.items.first.imageUrl!.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                order.items.first.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      Icons.image,
                                      color: Colors.blue[300],
                                    ),
                              ),
                            )
                            : Icon(Icons.shopping_bag, color: Colors.blue[300]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.items.isNotEmpty
                              ? order.items.first.productName
                              : 'Produk tidak tersedia',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(order.orderDate),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
              const SizedBox(height: 16),

              // Order Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Jumlah', '${order.totalQuantity} item'),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Harga Satuan',
                      currencyFormat.format(
                        order.items.isNotEmpty
                            ? order.items.first.unitPrice
                            : 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Total Harga',
                      currencyFormat.format(order.totalPrice),
                      isTotal: true,
                    ),
                    if (order.change > 0) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Kembalian',
                        currencyFormat.format(order.change),
                        textColor: Colors.green[600],
                      ),
                    ],
                  ],
                ),
              ),

              // Action Buttons (if needed)
              // if (order.status == 'pending') ...[
              //   const SizedBox(height: 12),
              //   Row(
              //     children: [
              //       Expanded(
              //         child: OutlinedButton(
              //           onPressed:
              //               () => _updateOrderStatus(
              //                 orderProvider,
              //                 order.id!,
              //                 'completed',
              //               ),
              //           style: OutlinedButton.styleFrom(
              //             foregroundColor: Colors.green,
              //             side: const BorderSide(color: Colors.green),
              //           ),
              //           child: const Text('Selesaikan'),
              //         ),
              //       ),
              //       const SizedBox(width: 8),
              //       Expanded(
              //         child: OutlinedButton(
              //           onPressed:
              //               () => _updateOrderStatus(
              //                 orderProvider,
              //                 order.id!,
              //                 'cancelled',
              //               ),
              //           style: OutlinedButton.styleFrom(
              //             foregroundColor: Colors.red,
              //             side: const BorderSide(color: Colors.red),
              //           ),
              //           child: const Text('Batalkan'),
              //         ),
              //       ),
              //     ],
              //   ),
              // ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        text = 'Selesai';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Dibatalkan';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor ?? (isTotal ? Colors.black : Colors.grey[600]),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 14 : 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: textColor ?? (isTotal ? Colors.black : Colors.grey[800]),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 14 : 12,
          ),
        ),
      ],
    );
  }

  void _updateOrderStatus(
    OrderProvider orderProvider,
    int orderId,
    String newStatus,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin mengubah status pesanan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                orderProvider.updateOrderStatus(orderId, newStatus);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Status pesanan berhasil diubah'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  void _showOrderDetails(
    BuildContext context,
    OrderModel order,
    OrderProvider orderProvider,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id_ID');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final firstItem = order.items.isNotEmpty ? order.items.first : null;

        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.blue),
              const SizedBox(width: 8),
              const Expanded(child: Text('Detail Pesanan')),
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
                // Product Image (hanya dari item pertama)
                if (firstItem?.imageUrl != null &&
                    firstItem!.imageUrl!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        firstItem.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Order Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Pesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (firstItem != null) ...[
                        _buildDetailRow(
                          'Produk',
                          order.items.first.productName,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow('Jumlah', '${firstItem.quantity} item'),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Harga Satuan',
                          currencyFormat.format(firstItem.unitPrice),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Tanggal Pesanan',
                        dateFormat.format(order.orderDate),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('Status', order.status),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Total Harga',
                        currencyFormat.format(order.totalPrice),
                        isTotal: true,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Jumlah Bayar',
                        currencyFormat.format(order.paymentAmount),
                      ),
                      if (order.change > 0) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Kembalian',
                          currencyFormat.format(order.change),
                          textColor: Colors.green[600],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            //   if (order.status == 'pending') ...[
            //     TextButton(
            //       onPressed: () {
            //         Navigator.of(context).pop();
            //         _updateOrderStatus(orderProvider, order.id!, 'completed');
            //       },
            //       style: TextButton.styleFrom(foregroundColor: Colors.green),
            //       child: const Text('Selesaikan'),
            //     ),
            //     TextButton(
            //       onPressed: () {
            //         Navigator.of(context).pop();
            //         _updateOrderStatus(orderProvider, order.id!, 'cancelled');
            //       },
            //       style: TextButton.styleFrom(foregroundColor: Colors.red),
            //       child: const Text('Batalkan'),
            //     ),
            //   ],
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}
