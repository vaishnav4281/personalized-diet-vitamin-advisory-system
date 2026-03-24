import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthService() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _user = await _storage.getUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Check network connectivity first
      if (!await _checkInternetConnection()) {
        throw Exception('No internet connection. Please check your network and try again.');
      }
      
      final response = await _api.login(email, password);
      dev.log('Login response keys: ${response.keys}', name: 'AuthService');
      dev.log('Login response: $response', name: 'AuthService');

      if (response['success'] == true) {
        // Backend returns: { "success": true, "message": "...", "user": { "id": 5, "name": "...", ... } }
        final userData = response['user'];
        if (userData != null && userData is Map<String, dynamic>) {
          _user = User.fromJson(userData);
        } else {
          // Fallback: build a minimal user from what we have
          _user = User(id: '', name: '', email: email);
        }

        // Save userId explicitly
        if (_user != null && _user!.id.isNotEmpty) {
          await _storage.saveUserId(_user!.id);
        }

        // Save token if provided (backend may not return one)
        final String? token = response['token']?.toString();
        if (token != null && token.isNotEmpty) {
          await _storage.saveToken(token);
        }

        if (_user != null) {
          await _storage.saveUser(_user!);
        }

        dev.log('Stored userId: ${_user?.id}', name: 'AuthService');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      dev.log('Login error: $e', name: 'AuthService');
      String errorMessage = 'Login failed';
      
      // Handle specific socket/network errors
      if (e.toString().contains('SocketException') || 
          e.toString().contains('errno 7') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Connection timed out')) {
        errorMessage = 'Network error: Unable to connect to server. Please check your internet connection and try again.';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage = 'Server is temporarily unavailable. Please try again in a few minutes.';
      } else if (e.toString().contains('Connection timed out')) {
        errorMessage = 'Connection timed out. Please check your internet connection and try again.';
      } else {
        errorMessage = e.toString();
      }
      
      _isLoading = false;
      notifyListeners();
      throw Exception(errorMessage);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _api.register(name, email, password);
      dev.log('Register response keys: ${response.keys}', name: 'AuthService');
      dev.log('Register response: $response', name: 'AuthService');

      if (response['success'] == true) {
        // Backend returns: { "success": true, "user_id": 5, "message": "..." }
        // Note: register does NOT return a "user" object — only user_id
        final userId = response['user_id']?.toString() ?? '';

        // Build user from available data
        if (response['user'] != null && response['user'] is Map<String, dynamic>) {
          _user = User.fromJson(response['user']);
        } else {
          _user = User(id: userId, name: name, email: email);
        }

        // Save userId explicitly
        if (userId.isNotEmpty) {
          await _storage.saveUserId(userId);
        }

        // Save token if provided
        final String? token = response['token']?.toString();
        if (token != null && token.isNotEmpty) {
          await _storage.saveToken(token);
        }

        if (_user != null) {
          await _storage.saveUser(_user!);
        }

        dev.log('Stored userId: $userId', name: 'AuthService');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      dev.log('Register error: $e', name: 'AuthService');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.clearUser();
    _user = null;
    notifyListeners();
  }
  
  // Check internet connectivity
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      try {
        // Fallback to check the API server directly
        final result = await InternetAddress.lookup('diet-health-app.onrender.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e) {
        return false;
      }
    }
  }
}
