import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auction_provider.dart';
import '../../widgets/auction/auction_card.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/navbar.dart';
import '../../widgets/auction/auction_search_bar.dart';
import '../../providers/profile_provider.dart';

class AuctionMenuScreen extends StatefulWidget {
  const AuctionMenuScreen({super.key});

  @override
  State<AuctionMenuScreen> createState() => _AuctionMenuScreenState();
}

class _AuctionMenuScreenState extends State<AuctionMenuScreen> {
  // bool _isInit = true;
  String _searchQuery = '';
  AuctionProvider? _auctionProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
      _auctionProvider?.loadAuctionItems();
      // _auctionProvider?.startAutoRefresh();
    });
  }

  Future<void> _onRefresh() async {
    await _auctionProvider?.loadAuctionItems();
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = Provider.of<AuctionProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profile;

    final filteredAuctions =
        auctionProvider.auctions.where((auction) {
          final title = auction.title.toLowerCase();
          return title.contains(_searchQuery.toLowerCase());
        }).toList();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Menu Lelang', showBackButton: false),
      body:
          auctionProvider.isLoading
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
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
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
                              targetPage: '/auction/detail',
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      floatingActionButton:
          profile?.role != 'biasa'
              ? FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: () {
                  Navigator.pushNamed(context, '/my-auction');
                },
                child: const Icon(Icons.settings, color: Colors.white),
              )
              : null,
      bottomNavigationBar: BottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/market');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
