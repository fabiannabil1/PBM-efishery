import 'package:flutter/material.dart';
import '../services/role_change_service.dart';

class RoleChangeProvider with ChangeNotifier {
  final RoleChangeService _roleChangeService = RoleChangeService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _requestStatus;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get requestStatus => _requestStatus;

  Future<bool> requestRoleChange(String reason) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // final result = await _roleChangeService.requestRoleChange(reason);
      await _roleChangeService.requestRoleChange(reason);
      _errorMessage = null;
      await checkRequestStatus(); // Refresh status after request
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkRequestStatus() async {
    try {
      _requestStatus = await _roleChangeService.checkRequestStatus();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _requestStatus = null;
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool get hasPendingRequest {
    return _requestStatus != null && _requestStatus!['status'] == 'pending';
  }

  String get requestStatusText {
    if (_requestStatus == null || _requestStatus!['status'] == 'none') {
      return 'Tidak ada pengajuan';
    }

    switch (_requestStatus!['status']) {
      case 'pending':
        return 'Menunggu persetujuan';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Status tidak diketahui';
    }
  }
}
