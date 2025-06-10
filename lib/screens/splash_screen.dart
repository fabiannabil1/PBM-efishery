import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool isButtonEnabled = false;

  void _onPhoneChanged(String value) {
    setState(() {
      isButtonEnabled = value.length >= 10 && value.length <= 14;
    });
  }

  void _onContinuePressed() {
    // Lanjut ke verifikasi atau dashboard
    debugPrint('Nomor HP: ${_phoneController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/nelayan.jpg', // Ganti dengan nama file ilustrasimu
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'Selamat Datang di eFisheryKu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan masuk atau daftar akun baru untuk bisa pakai seluruh fiturnya.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Nomor Hp',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  '${_phoneController.text.length}/14',
                  style: const TextStyle(color: Colors.grey),
                )
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 14,
              onChanged: _onPhoneChanged,
              decoration: InputDecoration(
                hintText: '08xxx',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isButtonEnabled ? _onContinuePressed : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: isButtonEnabled ? Colors.green : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Lanjutkan',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text.rich(
                TextSpan(
                  text: 'Butuh bantuan? ',
                  style: const TextStyle(color: Colors.black54),
                  children: [
                    TextSpan(
                      text: 'Hubungi Kami',
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                      // Tambahkan aksi jika ingin menggunakan GestureDetector atau InkWell
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
