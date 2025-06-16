// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileProvider? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to provider
    if (_provider == null) {
      _provider = Provider.of<ProfileProvider>(context, listen: false);
      _provider!.addListener(_handleProviderChanges);
    }
  }

  void _handleProviderChanges() {
    if (!mounted || _provider == null) return;

    if (_provider!.errorMessage != null) {
      _showErrorDialog(_provider!.errorMessage!);
      // Clear error after showing dialog
      _provider!.clearError();
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
          title: const Text(
            'Silahkan Login Ulang',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(
            // errorMessage,
            'Gagal Memuat Profil',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _handleLogout();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Login Ulang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.of(context).pop(); // Close dialog
            //     _handleRetryLogin();
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.blue,
            //     foregroundColor: Colors.white,
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 20,
            //       vertical: 12,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            //   child: const Text(
            //     'Login Ulang',
            //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            //   ),
            // ),
          ],
        );
      },
    );
  }

  void _handleLogout() {
    // Navigate to logout route
    Navigator.pushReplacementNamed(context, '/logout');
  }

  // void _handleRetryLogin() {
  //   // Navigate to login screen
  //   Navigator.pushReplacementNamed(context, '/login');
  // }

  @override
  void dispose() {
    // Safely remove listener using saved reference
    _provider?.removeListener(_handleProviderChanges);
    _provider = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profil', showBackButton: false),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Don't show error in UI anymore, it's handled by dialog
          final profile = provider.profile;
          if (profile == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Profil tidak ditemukan.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Blue gradient background
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Edit button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              Navigator.pushNamed(context, '/edit-profile');
                            },
                          ),
                        ),
                      ),

                      // Profile picture and name section
                      Container(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage:
                                        profile.profilePicture != null
                                            ? NetworkImage(
                                              profile.profilePicture!,
                                            )
                                            : const AssetImage(
                                                  'assets/images/profil.png',
                                                )
                                                as ImageProvider,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              profile.name ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              // decoration: BoxDecoration(
                              //   color: Colors.white.withOpacity(0.2),
                              //   borderRadius: BorderRadius.circular(20),
                              // ),
                              child: Text(
                                profile.bio ?? 'Bio',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                profile.role ?? 'User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Info cards
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildInfoCard(
                                icon: Icons.phone,
                                title: 'Phone Number',
                                value: profile.phone ?? '-',
                                iconColor: Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                icon: Icons.location_on,
                                title: 'Address',
                                value: profile.address ?? '',
                                iconColor: Colors.blue,
                              ),
                              const SizedBox(height: 24),

                              // Chat button
                              Container(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/chat-list');
                                  },
                                  icon: const Icon(Icons.chat_bubble_outline),
                                  label: const Text('Messages'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade400,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 2,
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Admin Article Management Button (only show for admin)
                              if (profile.role?.toLowerCase() == 'admin') ...[
                                Container(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/articles/admin',
                                      );
                                    },
                                    icon: const Icon(Icons.article),
                                    label: const Text('Kelola Artikel'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade400,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      elevation: 2,
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              ElevatedButton.icon(
                                onPressed: () {
                                  _showLogoutConfirmation();
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text('Logout'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 2,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/market');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/auctions/menu');
          }
        },
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Konfirmasi Logout',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Batal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/logout');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
