import 'package:flutter/foundation.dart';
import '../models/auth.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  String? _token;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService {
    _loadToken();
  }

  String? get token => _token;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  Future<void> _loadToken() async {
    _token = await _storageService.getToken();
    if (_token != null) {
      _apiService.setToken(_token);
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);
      
      _token = response.accessToken;
      _user = response.user;
      
      if (_token != null) {
        await _storageService.saveToken(_token!);
        _apiService.setToken(_token);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _error = null;
    await _storageService.clearToken();
    _apiService.setToken(null);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

