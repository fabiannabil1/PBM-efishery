class BidItem {
  final int id;
  final int auctionId;
  final String bidAmount;
  final String bidTime;
  final String bidderName;
  final int userId;

  BidItem({
    required this.id,
    required this.auctionId,
    required this.bidAmount,
    required this.bidTime,
    required this.bidderName,
    required this.userId,
  });

  factory BidItem.fromJson(Map<String, dynamic> json) {
    return BidItem(
      id: json['id'],
      auctionId: json['auction_id'],
      bidAmount: json['bid_amount'],
      bidTime: json['bid_time'],
      bidderName: json['bidder_name'],
      userId: json['user_id'],
    );
  }
}
