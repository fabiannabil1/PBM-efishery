import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0288D1), // Biru muda
              Color(0xFF01579B), // Biru tua
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Expanded(flex: 5, child: _buildHeader()),
                      _buildBottomSection(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo eFishery dengan background putih yang menonjol
        Container(
          height: 140,
          width: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: -5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/images/logo.png', // Logo hijau kebiruan Anda
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback icon dengan warna logo asli
                return const Icon(
                  Icons.water,
                  size: 60,
                  color: Color(0xFF00BCD4), // Cyan untuk logo hijau kebiruan
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 32),
        // const Text(
        //   'eFishery',
        //   style: TextStyle(
        //     fontSize: 32,
        //     fontWeight: FontWeight.bold,
        //     color: Colors.white,
        //     letterSpacing: 1.2,
        //   ),
        // ),
        // const SizedBox(height: 16),
        const Text(
          'Solusi Digital untuk Budidaya Perikanan Indonesia',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(
              255,
              247,
              247,
              247,
            ), // Warna teal sangat terang untuk subtitle
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Selamat Datang!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF01579B), // Biru tua untuk judul
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Budidaya ikan lebih efisien dengan teknologi terkini',
            style: TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0288D1), // Biru muda
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'MASUK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.register);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0288D1), // Biru muda
              side: const BorderSide(color: Color(0xFF0288D1), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'DAFTAR',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeatureIcon(Icons.shop, 'Lelang'),
              const SizedBox(width: 24),
              _buildFeatureIcon(Icons.shop_rounded, 'Marketplace'),
              const SizedBox(width: 24),
              _buildFeatureIcon(Icons.article, 'Tips'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE1F5FE), // Background biru sangat terang
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0288D1), // Biru muda untuk icon
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
