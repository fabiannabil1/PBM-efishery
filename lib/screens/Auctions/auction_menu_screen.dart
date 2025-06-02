import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auction_provider.dart';
import '../../widgets/auction_card.dart';
import '../../widgets/auction_search_bar.dart';

class AuctionMenuScreen extends StatefulWidget {
  const AuctionMenuScreen({super.key});

  @override
  State<AuctionMenuScreen> createState() => _AuctionMenuScreenState();
}

class _AuctionMenuScreenState extends State<AuctionMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<AuctionProvider>(
            context,
            listen: false,
          ).loadAuctionItems(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuctionProvider>(
      builder: (context, provider, _) {
        final auctions =
            provider.products.where((auction) {
              final query = _searchQuery.toLowerCase();
              return auction.title.toLowerCase().contains(query) ||
                  auction.locationName.toLowerCase().contains(query);
            }).toList();

        return Column(
          children: [
            AuctionSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onFilterTap: () {
                // Implement filter logic if needed
              },
            ),
            Expanded(
              child:
                  provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : auctions.isEmpty
                      ? const Center(child: Text('Tidak ada lelang ditemukan.'))
                      : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: auctions.length,
                        itemBuilder: (context, index) {
                          final auction = auctions[index];
                          return AuctionCard(
                            auction: auction,
                            onTap: () {
                              // Implement navigation to auction detail if needed
                            },
                          );
                        },
                      ),
            ),
          ],
        );
      },
    );
  }
}
// You can use AuctionMenuScreen as a widget in your app's navigation or as a body in a Scaffold elsewhere. );