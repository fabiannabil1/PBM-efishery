import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/token_storage.dart';

class AuthInterceptor implements InterceptorContract {
  @override
  Future<bool> shouldInterceptRequest() async => true;

  @override
  Future<bool> shouldInterceptResponse() async => true;

  @override
  Future<http.BaseRequest> interceptRequest({
    required http.BaseRequest request,
  }) async {
    try {
      final token = await TokenStorage.getToken();

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
    } catch (_) {
      // Optional: logging or error handling
    }

    return request;
  }

  @override
  Future<http.BaseResponse> interceptResponse({
    required http.BaseResponse response,
  }) async {
    if (response.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      // Opsional: navigasi ke login atau notifikasi logout
    }

    return response;
  }
}

class ExpiredTokenRetryPolicy extends RetryPolicy {
  @override
  Future<bool> shouldAttemptRetryOnResponse(http.BaseResponse response) async {
    // Contoh: hanya retry kalau 401
    if (response.statusCode == 401) {
      // Tambahkan logika refresh token jika diperlukan
      return false; // Ganti true jika berhasil refresh token dan ingin retry
    }
    return false;
  }
}
