import 'package:efishery/screens/Market/orders_screen.dart';
// import 'package:efishery/screens/dashboard_screen_users/product_screen/product_detail_screen.dart';
import 'package:efishery/screens/landing_screen.dart';
import 'package:efishery/screens/auth/register_screen.dart';
import 'package:efishery/screens/location/location_picker_screen.dart';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../screens/auth/login_screen.dart';
import '../screens/Home/home_screen.dart';
import '../screens/profile_screen/profile_screen.dart';
// import '../screens/dashboard_screen_users/dashboard_screen.dart';
import '../models/product.dart';
import '../screens/Auctions/my_auction_screen.dart';
import '../models/auction_item.dart';
import '../screens/Auctions/add_auction_screen.dart';
import '../screens/Auctions/my_auction_item_update_screen.dart';
import '../screens/Market/market_screen.dart';
import '../screens/Market/detail_produk.dart';
import '../screens/Auctions/auction_menu_screen.dart';
import '../screens/Auctions/auction_detail_screen.dart';
import '../screens/Auctions/my_auction_item_info.dart';
import '../screens/Auctions/bid_list_screen.dart';
import '../utils/token_storage.dart';
import '../screens/profile_screen/edit_profile_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_detail_screen.dart';

import '../screens/artikel_screen/artikeluser_screen.dart';
import '../screens/artikerladmin_screen/artikeladmin_screen.dart';
import '../screens/artikel_screen/add_article_screen.dart';
import '../screens/artikel_screen/edit_article_screen.dart';
import '../models/article_model.dart';
import '../screens/scan/scan_screen.dart';

class RouteGenerator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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
      // return MaterialPageRoute(builder: (_) => DashboardScreen());

      case AppRoutes.cartpage:
        return MaterialPageRoute(builder: (_) => OrdersScreen());

      case '/productdetails_page':
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(
          builder: (_) => DetailProdukScreen(product: product),
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

      case AppRoutes.locationPicker:
        return MaterialPageRoute(builder: (_) => const LocationPickerScreen());

      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case AppRoutes.chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());

      case AppRoutes.chatDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => ChatDetailScreen(
                partnerId: args['partnerId'],
                partnerName: args['partnerName'],
                partnerPhone: args['partnerPhone'],
              ),
        );

      case AppRoutes.articlesList:
        return MaterialPageRoute(builder: (_) => ArtikelUserScreen());

      case AppRoutes.articlesAdmin:
        return MaterialPageRoute(builder: (_) => ArtikelAdminScreen());

      case AppRoutes.articlesAdd:
        return MaterialPageRoute(builder: (_) => const AddArticleScreen());

      case AppRoutes.articlesEdit:
        final article = settings.arguments as ArticleModel;
        return MaterialPageRoute(
          builder: (_) => EditArticleScreen(article: article),
        );

      case AppRoutes.scan:
        return MaterialPageRoute(builder: (_) => const ScanScreen());

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
