import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/client.dart';
import '../services/api_service.dart';

class ThemeProvider with ChangeNotifier {
  final ApiService _apiService;
  
  Client? _currentClient;
  ThemeData? _theme;
  bool _isLoading = false;

  ThemeProvider({required ApiService apiService}) : _apiService = apiService {
    _updateTheme();
  }

  Client? get currentClient => _currentClient;
  ThemeData? get theme => _theme;
  bool get isLoading => _isLoading;
  Color get primaryColor => _currentClient != null 
      ? _parseColor(_currentClient!.primaryColor) 
      : Colors.blue;

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }


  void _updateTheme() {
    final color = primaryColor;
    _theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: color,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
    notifyListeners();
  }

  Future<void> refreshTheme({String? clientUrl}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentClient = await _apiService.getCurrentClient(clientUrl: clientUrl);
      _updateTheme();
    } catch (e) {
      // Error loading theme
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

