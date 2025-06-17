import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/auction_provider.dart';
import 'providers/user_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/article_provider.dart';
import 'providers/fish_detection_provider.dart';
import 'providers/product_provider.dart';

import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'utils/constants.dart';
import 'utils/token_storage.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (optional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize app-wide dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  final token = await TokenStorage.getToken();
  // print('Initial Token: $token'); // Debugging to see the initial token

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(sharedPreferences: sharedPreferences),
        ),
        ChangeNotifierProvider(create: (_) => AuctionProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
          // Add other providers here as needed
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider()..fetchProfile(),
        ),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => FishDetectionProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MyApp(initialToken: token),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? initialToken;

  const MyApp({super.key, this.initialToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eFishery App',
      theme: _buildAppTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.light, // or use system preference: ThemeMode.system
      initialRoute: initialToken != null ? AppRoutes.home : AppRoutes.landing,

      // initialRoute: AppRoutes.profile,
      onGenerateRoute: RouteGenerator.generateRoute,
      navigatorKey: Constants.navigatorKey,

      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // Hide keyboard when tapping outside text fields
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: child,
        );
      },
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
