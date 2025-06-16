import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCurrentUser() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Fetching current user...');
      _currentUser = await _userService.getCurrentUser();
      print('Fetched user: $_currentUser');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearUser() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  Future<String> getUsernameById(int id) async {
    try {
      return await _userService.getUserNameById(id);
    } catch (error) {
      throw Exception('Failed to fetch user name: $error');
    }
  }
}
