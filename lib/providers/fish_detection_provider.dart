import 'dart:io';
import 'package:flutter/material.dart';
import '../models/fish_detection_model.dart';
import '../services/fish_detection_service.dart';

class FishDetectionProvider extends ChangeNotifier {
  final FishDetectionService _service = FishDetectionService();

  bool _isLoading = false;
  String? _error;
  FishDetectionResponse? _detectionResult;

  bool get isLoading => _isLoading;
  String? get error => _error;
  FishDetectionResponse? get detectionResult => _detectionResult;

  Future<void> detectFish(File imageFile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _detectionResult = await _service.detectFish(imageFile);
    } catch (e) {
      _error = e.toString();
      _detectionResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _detectionResult = null;
    _error = null;
    notifyListeners();
  }
}
