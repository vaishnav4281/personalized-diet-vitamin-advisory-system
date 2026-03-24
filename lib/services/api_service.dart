import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {

  void _log(String method, String url, {dynamic body, int? statusCode, String? responseBody}) {
    dev.log('[$method] $url', name: 'ApiService');
    if (body != null) dev.log('  Request Body: ${jsonEncode(body)}', name: 'ApiService');
    if (statusCode != null) dev.log('  Response Status: $statusCode', name: 'ApiService');
    if (responseBody != null) dev.log('  Response Body: $responseBody', name: 'ApiService');
  }

  // ─── Auth ───────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    const String url = '${ApiConstants.baseUrl}${ApiConstants.login}';
    final body = {'email': email, 'password': password};
    _log('POST', url, body: body);

    try {
      final response = await _makeRequestWithRetry(
        () => http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ),
      );
      _log('POST', url, statusCode: response.statusCode, responseBody: response.body);
      return _handleResponse(response);
    } catch (e) {
      _log('POST', url, body: body, statusCode: null, responseBody: 'Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    const String url = '${ApiConstants.baseUrl}${ApiConstants.register}';
    final body = {'name': name, 'email': email, 'password': password};
    _log('POST', url, body: body);

    try {
      final response = await _makeRequestWithRetry(
        () => http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ),
      );
      _log('POST', url, statusCode: response.statusCode, responseBody: response.body);
      return _handleResponse(response);
    } catch (e) {
      _log('POST', url, body: body, statusCode: null, responseBody: 'Error: $e');
      rethrow;
    }
  }

  // ─── User Profile / Onboarding ──────────────────────────
  Future<Map<String, dynamic>> saveOnboarding(Map<String, dynamic> data, String token) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.onboarding}';
    _log('POST', url, body: data);

    final response = await http.post(
      Uri.parse(url),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    _log('POST', url, statusCode: response.statusCode, responseBody: response.body);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getProfile(int userId, String token) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.profile}/$userId';
    _log('GET', url);

    final response = await http.get(
      Uri.parse(url),
      headers: _authHeaders(token),
    );
    _log('GET', url, statusCode: response.statusCode, responseBody: response.body);
    return _handleResponse(response);
  }

  // ─── Health Analysis ────────────────────────────────────
  Future<Map<String, dynamic>> analyzeHealth(Map<String, dynamic> data, String token) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.analyzeHealth}';
    _log('POST', url, body: data);

    final response = await http.post(
      Uri.parse(url),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    _log('POST', url, statusCode: response.statusCode, responseBody: response.body);
    return _handleResponse(response);
  }

  // ─── Diet ───────────────────────────────────────────────
  Future<Map<String, dynamic>> getDietPlan(String userId, String token) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.getDietPlan}/$userId';
    _log('GET', url);

    final response = await http.get(
      Uri.parse(url),
      headers: _authHeaders(token),
    );
    _log('GET', url, statusCode: response.statusCode, responseBody: response.body);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> generateDiet(Map<String, dynamic> data, String token) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.generateDiet}';
    _log('POST', url, body: data);

    final response = await http.post(
      Uri.parse(url),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    _log('POST', url, statusCode: response.statusCode, responseBody: response.body);
    return _handleResponse(response);
  }

  // ─── Routine ────────────────────────────────────────────
  Future<Map<String, dynamic>> getRoutine(String userId, String token) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.getRoutine}/$userId';
    _log('GET', url);

    final response = await http.get(
      Uri.parse(url),
      headers: _authHeaders(token),
    );
    _log('GET', url, statusCode: response.statusCode, responseBody: response.body);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> generateRoutine(Map<String, dynamic> data, String token) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.generateRoutine}';
    _log('POST', url, body: data);

    final response = await http.post(
      Uri.parse(url),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    _log('POST', url, statusCode: response.statusCode, responseBody: response.body);
    return _handleResponse(response);
  }

  // ─── Progress ───────────────────────────────────────────
  Future<Map<String, dynamic>> logProgress(Map<String, dynamic> data, String token) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.logProgress}';
    _log('POST', url, body: data);

    final response = await http.post(
      Uri.parse(url),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    _log('POST', url, statusCode: response.statusCode, responseBody: response.body);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getProgress(String userId, String token) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.getProgress}/$userId';
    _log('GET', url);

    final response = await http.get(
      Uri.parse(url),
      headers: _authHeaders(token),
    );
    _log('GET', url, statusCode: response.statusCode, responseBody: response.body);
    return _handleResponse(response);
  }

  // ─── Reminders ──────────────────────────────────────────
  Future<Map<String, dynamic>> getReminders(String userId, String token) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.getReminders}/$userId';
    _log('GET', url);

    final response = await http.get(
      Uri.parse(url),
      headers: _authHeaders(token),
    );
    _log('GET', url, statusCode: response.statusCode, responseBody: response.body);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> addReminder(Map<String, dynamic> data, String token) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.addReminder}';
    _log('POST', url, body: data);

    final response = await http.post(
      Uri.parse(url),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    _log('POST', url, statusCode: response.statusCode, responseBody: response.body);
    return _handleResponse(response);
  }

  // ─── Helpers ────────────────────────────────────────────
  Map<String, String> _authHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(body);
    } else if (response.statusCode == 404) {
      // Return empty data for 404 - resource not created yet
      return {};
    } else {
      String errorMessage = 'Error: ${response.statusCode}';
      try {
        final decoded = jsonDecode(body);
        errorMessage = decoded['message'] ?? decoded['error'] ?? errorMessage;
      } catch (_) {
        // Non-JSON response body
      }
      throw Exception(errorMessage);
    }
  }
  
  // Make HTTP request with retry logic and timeout
  Future<http.Response> _makeRequestWithRetry(
    Future<http.Response> Function() requestFunction, {
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await requestFunction().timeout(timeout);
      } catch (e) {
        if (e is SocketException || 
            e.toString().contains('errno 7') ||
            e.toString().contains('Connection refused') ||
            e.toString().contains('Connection timed out')) {
          
          if (attempt == maxRetries - 1) {
            // Last attempt failed, rethrow with better message
            if (e.toString().contains('errno 7')) {
              throw Exception('Network error: Unable to connect to server. Please check your internet connection.');
            } else if (e is SocketException) {
              throw Exception('Network error: ${e.message}');
            } else {
              rethrow;
            }
          }
          
          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: 2 * attempt));
          dev.log('Retrying request... Attempt ${attempt + 2}', name: 'ApiService');
        } else {
          // Non-network error, don't retry
          rethrow;
        }
      }
    }
    
    throw Exception('Request failed after $maxRetries attempts');
  }
}
