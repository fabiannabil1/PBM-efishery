import 'package:efishery/screens/dashboard_screen_users/cart_screen/cart_screen.dart';
import 'package:efishery/screens/dashboard_screen_users/product_screen/product_detail_screen.dart';
import 'package:efishery/screens/landing_screen.dart';
import 'package:efishery/screens/auth/register_screen.dart';
import 'package:efishery/screens/location/location_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes/app_routes.dart';
import '../screens/auth/login_screen.dart';
import '../screens/Home/home_screen.dart';
import '../screens/profile_screen/profile_screen.dart';
import '../screens/dashboard_screen_users/dashboard_screen.dart';
import '../models/product.dart';
import '../screens/Auctions/my_auction_screen.dart';
import '../models/auction_item.dart';
import '../screens/Auctions/add_auction_screen.dart';
import '../screens/Auctions/my_auction_item_update_screen.dart';
import '../screens/Market/market_screen.dart';
import '../screens/Auctions/auction_menu_screen.dart';
import '../screens/Auctions/auction_detail_screen.dart';
import '../screens/Auctions/my_auction_item_info.dart';
import '../screens/Auctions/bid_list_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../utils/token_storage.dart';
import '../providers/user_provider.dart';
import '../screens/profile_screen/edit_profile_screen.dart';

class RouteGenerator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<Map<String, String>> _getChatUsernames(
    BuildContext context,
    int targetUserId,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Ensure current user data is loaded
    if (userProvider.currentUser == null) {
      await userProvider.fetchCurrentUser();
    }

    final currentUser = userProvider.currentUser;
    if (currentUser == null) {
      throw Exception('Current user not found');
    }

    // Get target user's name
    final targetUsername = await userProvider.getUsernameById(targetUserId);

    return {'current': currentUser.name, 'target': targetUsername};
  }

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

      case AppRoutes.myAuctionUpdate:
        final item = settings.arguments as AuctionItem;
        return MaterialPageRoute(
          builder: (_) => MyAuctionUpdateScreen(item: item),
        );

      case AppRoutes.auctionsMenu:
        return MaterialPageRoute(builder: (_) => const AuctionMenuScreen());

      case AppRoutes.market:
        return MaterialPageRoute(builder: (_) => const MarketScreen());

      case AppRoutes.bidList:
        final auctionId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BidListScreen(auctionId: auctionId),
        );

      case AppRoutes.myAuctionInfo:
        final item = settings.arguments as AuctionItem;
        return MaterialPageRoute(
          builder: (_) => MyAuctionInfoScreen(item: item),
        );

      case AppRoutes.chat:
        final targetUserId = settings.arguments as int?;
        if (targetUserId == null) {
          return MaterialPageRoute(
            builder:
                (_) => Scaffold(
                  body: Center(
                    child: Text('Error: Target user ID tidak ditemukan'),
                  ),
                ),
          );
        }

        return MaterialPageRoute(
          builder:
              (context) => FutureBuilder<Map<String, String>>(
                future: _getChatUsernames(context, targetUserId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Scaffold(
                      appBar: AppBar(title: Text('Chat')),
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return Scaffold(
                      appBar: AppBar(title: Text('Chat')),
                      body: Center(
                        child: Text(
                          'Error: ${snapshot.error ?? 'Data tidak tersedia'}',
                        ),
                      ),
                    );
                  }

                  final usernames = snapshot.data!;
                  return ChatScreen(
                    currentUsername: usernames['current']!,
                    targetUsername: usernames['target']!,
                  );
                },
              ),
        );

      case AppRoutes.locationPicker:
        return MaterialPageRoute(builder: (_) => const LocationPickerScreen());

      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

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
