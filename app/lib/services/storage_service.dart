import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _clientUrlKey = 'client_url';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> saveClientUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clientUrlKey, url);
  }

  Future<String?> getClientUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_clientUrlKey);
  }

  Future<void> clearClientUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clientUrlKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

