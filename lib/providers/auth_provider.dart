import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final SharedPreferences sharedPreferences;

  AuthProvider({required this.sharedPreferences});

  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    final response = await AuthService.login(
      phone,
      password,
    ); // akses static method lewat class

    _isLoading = false;
    _errorMessage = response['message'];

    if (response['success']) {
      _token = response['token'];
      await sharedPreferences.setString('token', _token!);
      notifyListeners();
      return true;
    } else {
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String phone,
    String password,
    String address,
    String name,
  ) async {
    _isLoading = true;
    notifyListeners();

    final response = await AuthService.register(
      phone,
      password,
      address,
      name,
    ); // akses static method lewat class

    _isLoading = false;
    _errorMessage = response['message'];

    if (response['success']) {
      notifyListeners();
      return true;
    } else {
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _token = null;
    sharedPreferences.remove('token');
    notifyListeners();
  }
}
