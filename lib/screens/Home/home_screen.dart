// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/navbar.dart';
import '../../widgets/article/articles_section.dart';
import '../../providers/article_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Fetch articles when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleProvider>().fetchArticles();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Welcome Section
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0F4C75),
                          Color(0xFF3282B8),
                          Color(0xFF0F4C75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3282B8).withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.wb_sunny_outlined,
                                    color: Color(0xFFFFE66D),
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Selamat Datang!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Temukan produk perikanan terbaik dan ikuti lelang terpercaya',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.set_meal_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Enhanced Quick Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Menu Cepat',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F4C75),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3282B8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Pilih layanan',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF3282B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Enhanced Quick Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEnhancedQuickActionButton(
                        context,
                        'Market',
                        Icons.storefront_outlined,
                        const Color(0xFF06D6A0),
                        const Color(0xFF06D6A0),
                        () =>
                            Navigator.pushReplacementNamed(context, '/market'),
                      ),
                      _buildEnhancedQuickActionButton(
                        context,
                        'Lelang',
                        Icons.gavel_outlined,
                        const Color(0xFFFF6B6B),
                        const Color(0xFFFF6B6B),
                        () => Navigator.pushReplacementNamed(
                          context,
                          '/auctions/menu',
                        ),
                      ),
                      _buildEnhancedQuickActionButton(
                        context,
                        'Artikel',
                        Icons.article_outlined,
                        const Color(0xFF4ECDC4),
                        const Color(0xFF4ECDC4),
                        () => Navigator.pushNamed(context, '/articles'),
                      ),
                      _buildEnhancedQuickActionButton(
                        context,
                        'Scan',
                        Icons.qr_code_scanner_outlined,
                        const Color(0xFF45B7D1),
                        const Color(0xFF45B7D1),
                        () => Navigator.pushNamed(context, '/scan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Enhanced Latest Auctions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3282B8).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.trending_up,
                              size: 20,
                              color: Color(0xFF3282B8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Lelang Terbaru',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F4C75),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF3282B8).withOpacity(0.3),
                          ),
                        ),
                        child: TextButton.icon(
                          onPressed:
                              () => Navigator.pushReplacementNamed(
                                context,
                                '/auctions/menu',
                              ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Color(0xFF3282B8),
                          ),
                          label: const Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF3282B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Enhanced Auction Cards
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return _buildEnhancedAuctionCard(index);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Articles Section with enhanced header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3282B8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.library_books_outlined,
                          size: 20,
                          color: Color(0xFF3282B8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Artikel Terbaru',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F4C75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const ArticlesSection(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // Already in Home
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/market');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/auctions/menu');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget _buildEnhancedQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    Color bgColor,
    VoidCallback onPressed,
  ) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (label.length * 100)),
      curve: Curves.elasticOut,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: bgColor.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: MaterialButton(
                  onPressed: onPressed,
                  color: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: bgColor.withOpacity(0.2), width: 1),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F4C75),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedAuctionCard(int index) {
    final List<Map<String, dynamic>> sampleData = [
      {
        'name': 'Ikan Tuna Segar',
        'price': 'Rp 150.000',
        'time': '2 jam lagi',
        'image': 'assets/images/petani-ikan.jpg',
        'status': 'Hot',
      },
      {
        'name': 'Udang Windu',
        'price': 'Rp 85.000',
        'time': '4 jam lagi',
        'image': 'assets/images/petani-ikan.jpg',
        'status': 'New',
      },
      {
        'name': 'Ikan Kakap Merah',
        'price': 'Rp 120.000',
        'time': '1 jam lagi',
        'image': 'assets/images/petani-ikan.jpg',
        'status': 'Ending',
      },
    ];

    final data = sampleData[index % sampleData.length];

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3282B8).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: AssetImage(data['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        data['status'] == 'Hot'
                            ? Colors.red
                            : data['status'] == 'New'
                            ? Colors.green
                            : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0F4C75),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  data['price'],
                  style: const TextStyle(
                    color: Color(0xFF3282B8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color:
                          data['status'] == 'Ending'
                              ? Colors.red
                              : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        data['time'],
                        style: TextStyle(
                          color:
                              data['status'] == 'Ending'
                                  ? Colors.red
                                  : Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
