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
  bool _isLoading = false;

  // Color constants
  static const _AppColors _colors = _AppColors();

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  @override
  void dispose() {
    _auctionProvider?.stopAutoRefresh();
    super.dispose();
  }

  // Initialize provider
  void _initializeProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
      _auctionProvider?.startAutoRefresh();
    });
  }

  // Navigation methods
  void _navigateToBidList() {
    Navigator.pushNamed(context, '/bid-list', arguments: widget.item.id);
  }

  void _navigateToUpdate() {
    Navigator.pushNamed(context, '/my-auction/update', arguments: widget.item);
  }

  // Auction actions
  Future<void> _closeAuction() async {
    final shouldClose = await _showConfirmationDialog(
      title: 'Tutup Lelang',
      message:
          'Yakin ingin menutup lelang ini? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Tutup',
      cancelText: 'Batal',
    );

    if (shouldClose == true) {
      // TODO: Implement close auction logic
      _showSnackBar('Fitur tutup lelang akan segera tersedia');
    }
  }

  Future<void> _deleteAuction() async {
    final shouldDelete = await _showConfirmationDialog(
      title: 'Hapus Lelang',
      message:
          'Yakin ingin menghapus lelang ini? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDestructive: true,
    );

    if (shouldDelete == true) {
      await _performDeleteAuction();
    }
  }

  Future<void> _performDeleteAuction() async {
    setState(() => _isLoading = true);

    try {
      final success = await _auctionProvider?.deleteAuction(widget.item.id);

      if (success == true && mounted) {
        _showSnackBar('Lelang berhasil dihapus');
        Navigator.pop(context);
      } else {
        _showSnackBar('Gagal menghapus lelang');
      }
    } catch (e) {
      debugPrint('Error deleting auction: $e');
      if (mounted) {
        _showSnackBar('Terjadi kesalahan saat menghapus lelang');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper methods
  Future<bool?> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: Text(message, style: const TextStyle(fontSize: 16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: Text(cancelText),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDestructive ? Colors.red : _colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // Widget builders
  Widget _buildHeroImage() {
    return Hero(
      tag: 'auction_image_${widget.item.id}',
      child: Container(
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            widget.item.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder:
                (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Gambar tidak dapat dimuat'),
                      ],
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _colors.lightBlue.withOpacity(0.1),
            _colors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _colors.lightBlue.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.gavel, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _colors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola lelang Anda dengan mudah',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
      margin: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : onPressed,
          icon: Icon(icon, size: 20),
          label: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor ?? Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            elevation: isDestructive ? 2 : 4,
            shadowColor: backgroundColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildActionButton(
          text: 'Lihat Penawaran',
          icon: Icons.visibility,
          onPressed: _navigateToBidList,
          backgroundColor: _colors.primary,
        ),
        _buildActionButton(
          text: 'Perbarui Data',
          icon: Icons.edit,
          onPressed: _navigateToUpdate,
          backgroundColor: _colors.secondary,
        ),
        _buildActionButton(
          text: 'Tutup Lelang',
          icon: Icons.lock,
          onPressed: _closeAuction,
          backgroundColor: _colors.lightBlue,
        ),
        _buildActionButton(
          text: 'Hapus Lelang',
          icon: Icons.delete,
          onPressed: _deleteAuction,
          backgroundColor: Colors.red[400]!,
          isDestructive: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(
        title: 'Informasi Lelang',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroImage(),
                  const SizedBox(height: 24),
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(child: _buildActionButtons()),
                  ),
                ],
              ),
            ),
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

// Color constants class
class _AppColors {
  const _AppColors();

  Color get darkBlue => const Color(0xFF1E3A8A);
  Color get secondary => const Color(0xFF2563EB);
  Color get primary => const Color(0xFF3B82F6);
  Color get lightBlue => const Color(0xFF60A5FA);
}
