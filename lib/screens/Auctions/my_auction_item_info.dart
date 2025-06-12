// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:efishery/models/auction_item.dart';
import '../../providers/auction_provider.dart';
import 'package:efishery/widgets/custom_appbar.dart';

class MyAuctionInfoScreen extends StatefulWidget {
  final AuctionItem item;

  const MyAuctionInfoScreen({super.key, required this.item});

  @override
  State<MyAuctionInfoScreen> createState() => _MyAuctionInfoScreenState();
}

class _MyAuctionInfoScreenState extends State<MyAuctionInfoScreen> {
  AuctionProvider? _auctionProvider;

  // Color palette
  static const List<Color> blueColors = [
    Color(0xFF1E3A8A), // blue-800
    Color(0xFF2563EB), // blue-600
    Color(0xFF3B82F6), // blue-500
    Color(0xFF60A5FA), // blue-400
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
      _auctionProvider?.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _auctionProvider?.stopAutoRefresh();
    super.dispose();
  }

  void _closeAuction() {}

  void _deleteAuction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Konfirmasi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: const Text(
              'Yakin ingin menghapus lelang ini?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      try {
        final success = await _auctionProvider?.deleteAuction(widget.item.id);
        if (success == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lelang berhasil dihapus')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus lelang')),
          );
        }
      }
    }
    if (confirm == true) {
      // final success = await _auctionProvider?.deleteAuction(widget.item.id);
      // if (success == true && mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Lelang berhasil dihapus')),
      //   );
      //   Navigator.pop(context);
      // }
    }
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    Color? foregroundColor,
    bool isDestructive = false,
  }) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: isDestructive ? 2 : 4,
          shadowColor: backgroundColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            blueColors[3].withOpacity(0.1),
            blueColors[2].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: blueColors[3].withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: blueColors[2],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.gavel, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: blueColors[0],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Kelola lelang Anda dengan mudah',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: 'Informasi Lelang', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Hero(
                tag: 'auction_image_${widget.item.title}',
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
                  child: Image.network(
                    widget.item.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder:
                        (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 80),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildActionButton(
                        text: 'Lihat Penawaran',
                        icon: Icons.visibility,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/bid-list',
                            arguments: widget.item.id,
                          );
                        },
                        backgroundColor: blueColors[2],
                      ),

                      _buildActionButton(
                        text: 'Perbarui Data',
                        icon: Icons.edit,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/my-auction/update',
                            arguments: widget.item,
                          );
                        },
                        backgroundColor: blueColors[1],
                      ),

                      _buildActionButton(
                        text: 'Tutup Lelang',
                        icon: Icons.lock,
                        onPressed: _closeAuction,
                        backgroundColor: blueColors[3],
                      ),

                      _buildActionButton(
                        text: 'Hapus Lelang',
                        icon: Icons.delete,
                        onPressed: _deleteAuction,
                        backgroundColor: Colors.red[400]!,
                        isDestructive: true,
                      ),

                      const SizedBox(height: 20),
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
}
