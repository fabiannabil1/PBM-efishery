import 'package:flutter/material.dart';
import '../services/auction_service.dart';
import '../models/auction_item.dart';

class AuctionProvider with ChangeNotifier {
  final AuctionService _auctionService = AuctionService();

  List<AuctionItem> _auctions = [];
  bool _isLoading = false;

  List<AuctionItem> get products => _auctions;
  bool get isLoading => _isLoading;

  Future<void> loadAuctionItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _auctions = await _auctionService.fetchAuctions();
    } catch (e) {
      print('Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
