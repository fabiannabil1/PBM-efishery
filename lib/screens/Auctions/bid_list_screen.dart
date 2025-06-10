import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bid_item.dart';
import '../../providers/auction_provider.dart';
import '../../widgets/custom-appbar.dart';
import 'package:intl/intl.dart';

class BidListScreen extends StatefulWidget {
  final int auctionId;

  const BidListScreen({super.key, required this.auctionId});

  @override
  State<BidListScreen> createState() => _BidListScreenState();
}

class _BidListScreenState extends State<BidListScreen> {
  late Future<List<BidItem>> _futureBids;

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
    final auctionProvider = Provider.of<AuctionProvider>(
      context,
      listen: false,
    );
    _futureBids = auctionProvider.fetchBidsForAuction(widget.auctionId);
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(amount);
  }

  String formatDate(String dateTimeStr) {
    // Parse RFC 1123 format like 'Sun, 08 Jun 2025 22:08:10 GMT'
    final dateTime =
        DateFormat(
          'EEE, dd MMM yyyy HH:mm:ss \'GMT\'',
          'en_US',
        ).parseUtc(dateTimeStr).toLocal();
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  String getTimeAgo(String dateTimeStr) {
    final dateTime =
        DateFormat(
          'EEE, dd MMM yyyy HH:mm:ss \'GMT\'',
          'en_US',
        ).parseUtc(dateTimeStr).toLocal();

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  Widget _buildBidCard(BidItem bid, int index, int totalBids) {
    final isHighestBid = index == 0;
    final bidAmount = double.parse(bid.bidAmount);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient:
            isHighestBid
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    blueColors[2].withOpacity(0.1),
                    blueColors[1].withOpacity(0.05),
                  ],
                )
                : null,
        color: isHighestBid ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            isHighestBid
                ? Border.all(color: blueColors[2], width: 2)
                : Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color:
                isHighestBid
                    ? blueColors[2].withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
            blurRadius: isHighestBid ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar with ranking
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          isHighestBid
                              ? [blueColors[1], blueColors[2]]
                              : [Colors.grey[400]!, Colors.grey[500]!],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 24),
                ),
                if (isHighestBid)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 16),

            // Bid info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bid.bidderName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isHighestBid ? blueColors[0] : Colors.black87,
                          ),
                        ),
                      ),
                      if (isHighestBid)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: blueColors[2],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Tertinggi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Bid amount
                  Text(
                    formatCurrency(bidAmount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isHighestBid ? blueColors[1] : blueColors[2],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Time info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        getTimeAgo(bid.bidTime),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${formatDate(bid.bidTime)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Rank badge
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isHighestBid ? blueColors[2] : Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  '#${index + 1}',
                  style: TextStyle(
                    color: isHighestBid ? Colors.white : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(List<BidItem> bids) {
    if (bids.isEmpty) return const SizedBox.shrink();

    final highestBid = double.parse(bids.first.bidAmount);
    final totalBids = bids.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [blueColors[1], blueColors[2]],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: blueColors[2].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Penawaran Tertinggi',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(highestBid),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$totalBids',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Penawar',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: blueColors[3].withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(Icons.gavel_outlined, size: 40, color: blueColors[2]),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Penawaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: blueColors[0],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lelang ini belum memiliki penawaran.\nPantau terus untuk update terbaru!',
            textAlign: TextAlign.center,
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
      appBar: const CustomAppBar(title: 'Daftar Penawar', showBackButton: true),
      body: FutureBuilder<List<BidItem>>(
        future: _futureBids,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(blueColors[2]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat data penawaran...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi Kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[400],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final bids = snapshot.data ?? [];

          if (bids.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: blueColors[2],
            onRefresh: () async {
              setState(() {
                final auctionProvider = Provider.of<AuctionProvider>(
                  context,
                  listen: false,
                );
                _futureBids = auctionProvider.fetchBidsForAuction(
                  widget.auctionId,
                );
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatsHeader(bids),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bids.length,
                    itemBuilder: (context, index) {
                      return _buildBidCard(bids[index], index, bids.length);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
