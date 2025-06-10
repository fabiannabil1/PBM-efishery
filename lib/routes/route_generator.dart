// import 'dart:ffi';

import 'package:efishery/screens/dashboard_screen_users/cart_screen/cart_screen.dart';
import 'package:efishery/screens/dashboard_screen_users/product_screen/product_detail_screen.dart';
import 'package:efishery/screens/landing_screen.dart';
import 'package:efishery/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../screens/auth/login_screen.dart';
import '../screens/Home/home_screen.dart';
import '../screens/profile_screen/profile_screen.dart';
import '../screens/dashboard_screen_users/dashboard_screen.dart';
import '../models/product.dart';
import '../screens/Auctions/my_auction_screen.dart';
import '../models/auction_item.dart'; // Make sure this path matches where AuctionItem is defined
import '../screens/Auctions/add_auction_screen.dart';
import '../screens/Auctions/my_auction_item_detail_screen.dart';
import '../screens/Market/market_screen.dart';
import '../screens/Auctions/auction_menu_screen.dart';
import '../screens/Auctions/auction_detail_screen.dart';

import '../utils/token_storage.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.logout:
        TokenStorage.deleteToken();
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.landing:
        return MaterialPageRoute(builder: (_) => const LandingScreen());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppRoutes.dashboardusers:
        return MaterialPageRoute(builder: (_) => DashboardScreen());

      case AppRoutes.cartpage:
        return MaterialPageRoute(builder: (_) => CartScreen());

      case AppRoutes.productdetails:
        return MaterialPageRoute(
          builder:
              (_) => ProductDetailPage(
                product: settings.arguments as ProductModel,
              ),
        );

      case AppRoutes.myAuction:
        return MaterialPageRoute(builder: (_) => const MyAuction());

      case AppRoutes.addAuction:
        return MaterialPageRoute(builder: (_) => const AddAuctionScreen());

      case AppRoutes.auctionsDetail:
        final item = settings.arguments as AuctionItem;
        return MaterialPageRoute(
          builder: (_) => AuctionDetailScreen(item: item),
        );

      case AppRoutes.myAuctionDetail:
        final item = settings.arguments as AuctionItem;
        return MaterialPageRoute(
          builder: (_) => MyAuctionDetailScreen(item: item),
        );

      case AppRoutes.auctionsMenu:
        return MaterialPageRoute(builder: (_) => const AuctionMenuScreen());

      case AppRoutes.market:
        return MaterialPageRoute(builder: (_) => const MarketScreen());

      // Tambahkan route lainnya di sini
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('Route tidak ditemukan: ${settings.name}'),
                ),
              ),
        );
    }
  }
}
