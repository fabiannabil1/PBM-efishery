import 'package:efishery/providers/auth_provider.dart';
import 'package:efishery/providers/profile_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/continue_button.dart';
import '../../widgets/text_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isButtonEnabled = false;
  bool _obscurePassword = true;

  void _validateInputs() {
    setState(() {
      isButtonEnabled =
          _phoneController.text.length >= 10 &&
          _phoneController.text.length <= 14 &&
          _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _onContinuePressed() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _phoneController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Load user profile after successful login
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      await profileProvider.fetchProfile(); // Use the provider to load profile
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');

      // Navigator.pushReplacementNamed(context, '/auctions/menu');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Login gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Akun')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 2),
            Image.asset(
              'assets/images/petani-ikan.jpg',
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'Selamat Datang di eFisheryKu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan masuk atau daftar akun baru untuk bisa pakai seluruh fiturnya.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 24),
            CustomInputField(
              controller: _phoneController,
              onChanged: (value) => _validateInputs(),
              label: 'Nomor HP',
              hintText: '08xxx',
              keyboardType: TextInputType.phone,
              maxLength: 14,
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              onChanged: (value) => _validateInputs(),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Masukkan password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),
            ContinueButton(
              isEnabled: isButtonEnabled,
              onPressed: isButtonEnabled ? _onContinuePressed : null,
              label: 'Masuk',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
