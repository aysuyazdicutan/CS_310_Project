import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode_enabled';
  
  bool _darkModeEnabled = false;
  bool _isLoading = true;

  bool get darkModeEnabled => _darkModeEnabled;
  bool get isLoading => _isLoading;

  /// Load preferences from SharedPreferences
  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _darkModeEnabled = prefs.getBool(_darkModeKey) ?? false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle dark mode and persist the preference
  Future<void> toggleDarkMode(bool value) async {
    if (_darkModeEnabled == value) return;
    
    _darkModeEnabled = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, value);
    } catch (e) {
      debugPrint('Error saving dark mode preference: $e');
      // Revert on error
      _darkModeEnabled = !value;
      notifyListeners();
    }
  }
}

