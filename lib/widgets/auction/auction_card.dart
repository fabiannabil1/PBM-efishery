import 'package:flutter/material.dart';
import '../../models/auction_item.dart';
import 'package:intl/intl.dart';

class AuctionCard extends StatelessWidget {
  final AuctionItem item;
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  final String targetPage;

  AuctionCard({super.key, required this.item, required this.targetPage});

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar untuk responsivitas
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Tentukan ukuran berdasarkan lebar layar
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;
    // final isLargeScreen = screenWidth >= 400;

    // Responsif untuk tinggi gambar - dikurangi sedikit
    final imageHeight =
        isSmallScreen
            ? 95.0
            : isMediumScreen
            ? 105.0
            : 115.0;

    // Responsif untuk ukuran font
    final titleFontSize =
        isSmallScreen
            ? 14.0
            : isMediumScreen
            ? 15.0
            : 16.0;

    final priceFontSize =
        isSmallScreen
            ? 16.0
            : isMediumScreen
            ? 17.0
            : 18.0;

    final subTextFontSize =
        isSmallScreen
            ? 12.0
            : isMediumScreen
            ? 13.0
            : 14.0;

    final dateFontSize =
        isSmallScreen
            ? 11.0
            : isMediumScreen
            ? 12.0
            : 13.0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, targetPage, arguments: item);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          // Batasi tinggi maksimum card dengan buffer untuk overflow
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.32, // Dikurangi dari 35% ke 32%
            minHeight: 190, // Dikurangi dari 200px ke 190px
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bagian Gambar dengan Stack
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Image.network(
                      item.imageUrl,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            height: imageHeight,
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.broken_image,
                              size: isSmallScreen ? 40 : 50,
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 12,
                        vertical: isSmallScreen ? 4 : 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            item.status == 'open' ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.status.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Bagian Konten dengan Expanded untuk fleksibilitas
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(
                    isSmallScreen ? 6.0 : 8.0,
                  ), // Dikurangi padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bagian atas: Title dan Location
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: isSmallScreen ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: isSmallScreen ? 1 : 2,
                          ), // Dikurangi spacing
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: isSmallScreen ? 14 : 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.locationName,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: subTextFontSize,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Bagian bawah: Price dan Deadline
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currencyFormat.format(
                              double.parse(item.currentPrice.toString()),
                            ),
                            style: TextStyle(
                              fontSize: priceFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: isSmallScreen ? 2 : 4,
                          ), // Dikurangi spacing
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: isSmallScreen ? 14 : 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  "Berakhir: ${DateFormat('dd MMM yyyy').format(item.deadline.toLocal())}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: dateFontSize,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
