import 'package:efishery/screens/landing_screen.dart';
import 'package:efishery/screens/register_screen.dart';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen/profile_screen.dart';
import '../screens/profile_screen/editprofile_screen.dart';
import '../screens/artikel_screen/artikeluser_screen.dart';

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
