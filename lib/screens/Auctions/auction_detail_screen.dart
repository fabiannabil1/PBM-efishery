// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/auction_item.dart';
import '../../widgets/custom_appbar.dart';
import '../../services/auction_service.dart';
import '../../services/chat_service.dart';
import '../../providers/auction_provider.dart';
import '../../providers/auth_provider.dart';

class AuctionDetailScreen extends StatefulWidget {
  final AuctionItem item;

  const AuctionDetailScreen({super.key, required this.item});

  @override
  State<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  AuctionProvider? _auctionProvider;

  @override
  void initState() {
    super.initState();
    // Start auto-refresh when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
      _auctionProvider?.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    // Stop auto-refresh when screen is closed
    _auctionProvider?.stopAutoRefresh();
    super.dispose();
  }

  AuctionItem _getUpdatedItem(BuildContext context, {bool listen = true}) {
    final provider = Provider.of<AuctionProvider>(context, listen: listen);
    final updatedItem = provider.auctions.firstWhere(
      (element) => element.id == widget.item.id,
      orElse: () => widget.item,
    );
    return updatedItem;
  }

  @override
  Widget build(BuildContext context) {
    final item = _getUpdatedItem(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final String itemName =
        item.title.length > 20
            ? '${item.title.substring(0, 20)}...'
            : item.title;

    // Calculate time remaining
    final timeRemaining = item.deadline.difference(DateTime.now());
    final bool isExpired = timeRemaining.isNegative;

    return Scaffold(
      appBar: CustomAppBar(title: itemName, showBackButton: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Hero Animation
            Hero(
              tag: 'auction_image_${item.title}',
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
                  child: Image.network(
                    item.imageUrl,
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
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder:
                        (context, error, stackTrace) => Container(
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
                  // Title
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(item.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor(item.status)),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        color: _getStatusColor(item.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info Cards
                  _buildInfoCard(
                    context,
                    icon: Icons.location_on,
                    title: 'Lokasi',
                    value: item.locationName,
                    iconColor: Colors.red,
                  ),
                  const SizedBox(height: 12),

                  _bidInfoCard(
                    context,
                    icon: Icons.monetization_on,
                    title: 'Current Price - Tap to View Bids',
                    value: currencyFormat.format(
                      num.tryParse(item.currentPrice) ?? 0,
                    ),
                    iconColor: Colors.green,
                    valueStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green[700],
                    ),
                    onTap:
                        () => Navigator.pushNamed(
                          context,
                          '/bid-list',
                          arguments: item.id,
                        ),
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    context,
                    icon: Icons.schedule,
                    title: 'Berakhir',
                    value: DateFormat(
                      'dd MMM yyyy, HH:mm',
                    ).format(item.deadline),
                    iconColor: isExpired ? Colors.red : Colors.orange,
                    trailing:
                        isExpired
                            ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'BERAKHIR',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatTimeRemaining(timeRemaining),
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (!isExpired) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement bid functionality
                              _showBidDialog(context, item.id);
                            },
                            icon: const Icon(Icons.gavel),
                            label: const Text('Ajukan Penawaran'),
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
                        const SizedBox(width: 8),

                        ElevatedButton(
                          onPressed: () async {
                            final token =
                                Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                ).token;
                            if (token == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please login first'),
                                ),
                              );
                              return;
                            }

                            try {
                              final result = await ChatService.getUserByPhone(
                                token,
                                item.userId.toString(),
                              );
                              if (result['success']) {
                                final user = result['user'];
                                Navigator.pushNamed(
                                  context,
                                  '/chat-detail',
                                  arguments: {
                                    'partnerId': item.userId,
                                    'partnerName': user['name'] ?? 'User',
                                    'partnerPhone': user['phone'],
                                  },
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result['message'])),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.grey[700],
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.timer_off,
                            color: Colors.red[700],
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lelang Telah Berakhir',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
                  style:
                      valueStyle ??
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

  Widget _bidInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    TextStyle? valueStyle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    style:
                        valueStyle ??
                        const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'active':
        return Colors.green;
      case 'berakhir':
      case 'ended':
        return Colors.red;
      case 'menunggu':
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} hari';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} jam';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} menit';
    } else {
      return 'Berakhir segera';
    }
  }

  void _showBidDialog(BuildContext context, int itemId) {
    final item = _getUpdatedItem(context, listen: false);
    final TextEditingController bidController = TextEditingController();
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // Get current item before showing dialog
    final currentPrice = item.currentPrice;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajukan Penawaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Harga saat ini: ${currencyFormat.format(num.tryParse(currentPrice) ?? 0)}',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah penawaran',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final bidText = bidController.text;
                final bidAmount = double.tryParse(bidText);
                if (bidAmount == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nominal penawaran tidak valid'),
                    ),
                  );
                  return;
                }
                try {
                  final auctionService = AuctionService();
                  await auctionService.placeBid(itemId, bidAmount);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Penawaran berhasil diajukan'),
                    ),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal mengajukan penawaran: $e')),
                  );
                }
              },
              child: const Text('Ajukan'),
            ),
          ],
        );
      },
    );
  }
}
