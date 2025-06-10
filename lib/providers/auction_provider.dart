import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auction_service.dart';
import '../models/auction_item.dart';

class AuctionProvider with ChangeNotifier {
  final AuctionService _auctionService = AuctionService();
  Timer? _refreshTimer;
  Timer? _refreshMyItemTimer;

  List<AuctionItem> _auctions = [];
  List<AuctionItem> _myAuctions = [];
  bool _isLoading = false;
  bool _isLoadingMyAuction = false;
  bool _isAutoRefreshEnabled = false;
  bool _isAutoRefreshMyItemEnabled = false;

  List<AuctionItem> get products => _auctions;
  List<AuctionItem> get myProducts => _myAuctions;
  bool get isLoading => _isLoading;
  bool get isLoadingMyAuction => _isLoadingMyAuction;
  bool get isAutoRefreshEnabled => _isAutoRefreshEnabled;
  bool get isAutoRefreshMyItemEnabled => _isAutoRefreshMyItemEnabled;

  void startAutoRefresh() {
    if (!_isAutoRefreshEnabled) {
      _isAutoRefreshEnabled = true;
      // Initial load
      loadAuctionItems();
      // Set up timer for periodic updates
      _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        loadAuctionItems();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void startAutoRefreshMyItem() {
    if (!_isAutoRefreshMyItemEnabled) {
      _isAutoRefreshMyItemEnabled = true;
      // Initial load
      loadMyAuctionItems();
      // Set up timer for periodic updates
      _refreshMyItemTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        loadMyAuctionItems();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void stopAutoRefresh() {
    if (_isAutoRefreshEnabled) {
      _refreshTimer?.cancel();
      _refreshTimer = null;
      _isAutoRefreshEnabled = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
    if (_isAutoRefreshMyItemEnabled) {
      _refreshMyItemTimer?.cancel();
      _refreshMyItemTimer = null;
      _isAutoRefreshMyItemEnabled = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  Future<void> loadAuctionItems() async {
    if (_isLoading) return; // Prevent multiple simultaneous calls

    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final newAuctions = await _auctionService.fetchAuctions();
      _auctions = newAuctions;
    } catch (e) {
      // print('Error: $e');
    }

    _isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> loadMyAuctionItems() async {
    if (_isLoadingMyAuction) return; // Prevent multiple simultaneous calls

    _isLoadingMyAuction = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final newAuctions = await _auctionService.fetchMyAuctions();
      _myAuctions = newAuctions;
    } catch (e) {
      // print('Error: $e');
    }

    _isLoadingMyAuction = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<bool> updateAuction({
    required int auctionId,
    required String title,
    required String description,
    required double startingPrice,
    required DateTime deadline,
    required int locationId,
  }) async {
    try {
      final result = await _auctionService.updateAuction(
        auctionId: auctionId,
        title: title,
        description: description,
        startingPrice: startingPrice,
        deadline: deadline,
        locationId: locationId,
      );
      await loadAuctionItems();
      await loadMyAuctionItems();
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
