import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auction_provider.dart';
import '../../models/auction_item.dart';

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
      appBar: AppBar(title: const Text("Daftar Lelang")),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: provider.products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 kolom
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
    );
  }
}

class AuctionCard extends StatelessWidget {
  final AuctionItem item;

  const AuctionCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              item.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 120),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item.locationName,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text("Harga: Rp${item.currentPrice}"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "Tutup: ${item.deadline.toLocal().toString().split(' ').first}",
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.status.toUpperCase(),
              style: TextStyle(
                color: item.status == 'open' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
