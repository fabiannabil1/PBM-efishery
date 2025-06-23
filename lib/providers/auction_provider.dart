import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auction_service.dart';
import '../models/auction_item.dart';
import '../models/bid_item.dart';

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

  List<AuctionItem> get auctions => _auctions;
  List<AuctionItem> get myAuctions => _myAuctions;
  bool get isLoading => _isLoading;
  bool get isLoadingMyAuction => _isLoadingMyAuction;

  void startAutoRefresh() {
    if (_isAutoRefreshEnabled) return;

    _isAutoRefreshEnabled = true;
    loadAuctionItems();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => loadAuctionItems(),
    );
    _notify();
  }

  void startAutoRefreshMyItem() {
    if (_isAutoRefreshMyItemEnabled) return;

    _isAutoRefreshMyItemEnabled = true;
    loadMyAuctionItems();
    _refreshMyItemTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => loadMyAuctionItems(),
    );
    _notify();
  }

  void stopAutoRefresh() {
    if (_isAutoRefreshEnabled) {
      _refreshTimer?.cancel();
      _refreshTimer = null;
      _isAutoRefreshEnabled = false;
    }

    if (_isAutoRefreshMyItemEnabled) {
      _refreshMyItemTimer?.cancel();
      _refreshMyItemTimer = null;
      _isAutoRefreshMyItemEnabled = false;
    }

    _notify();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  Future<void> loadAuctionItems() async {
    if (_isLoading) return;

    _isLoading = true;
    _notify();

    try {
      _auctions = await _auctionService.fetchAuctions();
    } catch (_) {
      // Log or handle error if needed
    }

    _isLoading = false;
    _notify();
  }

  Future<void> loadMyAuctionItems() async {
    if (_isLoadingMyAuction) return;

    _isLoadingMyAuction = true;
    _notify();

    try {
      _myAuctions = await _auctionService.fetchMyAuctions();
    } catch (_) {
      // Log or handle error if needed
    }

    _isLoadingMyAuction = false;
    _notify();
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

  void _notify() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<List<BidItem>> fetchBidsForAuction(int auctionId) async {
    try {
      return await _auctionService.fetchBidsForAuction(auctionId);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteAuction(int auctionId) async {
    try {
      final result = await _auctionService.deleteAuction(auctionId);
      await loadAuctionItems();
      await loadMyAuctionItems();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> closeAuction(int auctionId) async {
    try {
      final result = await _auctionService.closeAuction(auctionId);
      await loadAuctionItems();
      await loadMyAuctionItems();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getHighestBid(int auctionId) async {
    try {
      return await _auctionService.getHighestBid(auctionId);
    } catch (e) {
      rethrow;
    }
  }
}
