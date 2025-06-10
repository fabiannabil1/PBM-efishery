import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auction_provider.dart';
import '../../widgets/auction/auction_card.dart';
import '../../widgets/custom-appbar.dart';
import '../../widgets/auction/auction_search_bar.dart';

class MyAuction extends StatefulWidget {
  const MyAuction({super.key});

  @override
  State<MyAuction> createState() => _MyAuctionState();
}

class _MyAuctionState extends State<MyAuction> {
  // bool _isInit = true;
  String _searchQuery = '';
  AuctionProvider? _auctionProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
      _auctionProvider?.loadMyAuctionItems();
      // _auctionProvider?.startAutoRefreshMyItem();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuctionProvider>(context);

    final filteredAuctions =
        provider.myAuctions.where((auction) {
          final title = auction.title.toLowerCase();
          return title.contains(_searchQuery.toLowerCase());
        }).toList();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Item Lelangku', showBackButton: true),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    AuctionSearchBar(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: GridView.builder(
                        itemCount: filteredAuctions.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemBuilder: (context, index) {
                          final auction = filteredAuctions[index];
                          return AuctionCard(
                            item: auction,
                            targetPage: '/my-auction/detail',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.pushNamed(context, '/add-auction');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
