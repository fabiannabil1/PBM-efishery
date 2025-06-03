import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auction_provider.dart';
import '../../widgets/auction/auction_card.dart';
import '../../widgets/custom-appbar.dart';
import '../../widgets/navbar.dart';

class AuctionMenuScreen extends StatefulWidget {
  const AuctionMenuScreen({super.key});

  @override
  State<AuctionMenuScreen> createState() => _AuctionMenuScreenState();
}

class _AuctionMenuScreenState extends State<AuctionMenuScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<AuctionProvider>(context, listen: false);
        if (provider.products.isEmpty && !provider.isLoading) {
          provider.loadAuctionItems();
        }
      });
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuctionProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Menu Lelang', showBackButton: true),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: provider.products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final auction = provider.products[index];
                    return AuctionCard(item: auction);
                  },
                ),
              ),
      bottomNavigationBar: BottomNav(
        currentIndex: 2, // Index untuk menu Lelang
        onTap: (index) {
          // Navigasi sesuai index
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/market');
          } else if (index == 2) {
            // Sudah di halaman Lelang
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
