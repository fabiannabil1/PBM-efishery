import 'package:efishery/screens/landing_screen.dart';
import 'package:efishery/screens/register_screen.dart';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen/profile_screen.dart';
<<<<<<< HEAD
import '../screens/Auctions/auction_menu_screen.dart';
import '../screens/Market/market_screen.dart';
import '../screens/Auctions/auction_detail_screen.dart';
import '../screens/Auctions/my_auction_screen.dart';
import '../models/auction_item.dart'; // Make sure this path matches where AuctionItem is defined
import '../screens/Auctions/add_auction_screen.dart';
import '../screens/Auctions/my_auction_item_detail_screen.dart';

import '../utils/token_storage.dart';
=======
import '../screens/profile_screen/editprofile_screen.dart';
import '../screens/artikel_screen/artikeluser_screen.dart';
>>>>>>> 6cbc70aa07882201b826153d62817e3cdabca32e

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.landing:
        return MaterialPageRoute(builder: (_) => const LandingScreen());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppRoutes.editprofile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case AppRoutes.artikeluser:
        return MaterialPageRoute(builder: (_) => const ArtikeluserScreen());

      case AppRoutes.myAuction:
        return MaterialPageRoute(builder: (_) => const MyAuction());

      case AppRoutes.addAuction:
        return MaterialPageRoute(builder: (_) => const AddAuctionScreen());

      case AppRoutes.myAuctionDetail:
        final item = settings.arguments as AuctionItem;
        return MaterialPageRoute(
          builder: (_) => MyAuctionDetailScreen(item: item),
        );

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
