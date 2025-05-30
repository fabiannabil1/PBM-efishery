import 'package:efishery/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/continue_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  bool isButtonEnabled = false;

  void _validateInputs() {
    setState(() {
      isButtonEnabled =
          _nameController.text.isNotEmpty &&
          _phoneController.text.length >= 10 &&
          _phoneController.text.length <= 14 &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text == _passwordController.text;
    });
  }

  Future<void> _submitRegister() async {
    //on going
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      _nameController.text,
      _phoneController.text,
      _passwordController.text,
      _addressController.text,
    );
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Register gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(),
              Image.asset(
                'assets/images/petani-ikan.jpg',
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 2),
              const Text(
                'Selamat Datang di eFisheryKu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              const Text(
                'Silakan masuk atau daftar akun baru untuk bisa pakai seluruh fiturnya.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                onChanged: (value) => _validateInputs(),
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Nama harus diisi'
                            : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                onChanged: (value) => _validateInputs(),
                decoration: const InputDecoration(labelText: 'Nomor HP'),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Nomor HP harus diisi'
                            : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                onChanged: (value) => _validateInputs(),
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator:
                    (value) =>
                        value == null || value.length < 8
                            ? 'Minimal 8 karakter'
                            : null,
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _confirmPasswordController,
                onChanged: (value) => _validateInputs(),
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator:
                    (value) =>
                        value != _passwordController.text
                            ? 'Password tidak cocok'
                            : null,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _addressController,
                onChanged: (value) => _validateInputs(),
                decoration: const InputDecoration(labelText: 'Alamat'),
                obscureText: false,
              ),

              const SizedBox(height: 24),
              ContinueButton(
                isEnabled: isButtonEnabled,
                onPressed: isButtonEnabled ? () => _submitRegister() : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
