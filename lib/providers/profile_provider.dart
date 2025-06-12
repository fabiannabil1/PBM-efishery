import 'dart:io';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/user_service.dart';

class ProfileProvider with ChangeNotifier {
  Profile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  final UserService _userService = UserService();

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _userService.getFullProfile(); // ganti dari getCurrentUser()
      _profile = Profile.fromJson(result);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? address,
    String? bio,
    File? imageFile,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _userService.updateUserProfile(
        name: name,
        address: address,
        bio: bio,
        imageFile: imageFile,
      );
      if (success) {
        await fetchProfile(); // Fetch updated profile data
      } else {
        _errorMessage = 'Failed to update profile';
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
