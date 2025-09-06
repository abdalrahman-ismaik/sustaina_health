import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }
  
  static const String _themeKey = 'app_theme_mode';
  
  Future<void> _loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String themeModeString = prefs.getString(_themeKey) ?? 'system';
    state = _stringToThemeMode(themeModeString);
  }
  
  Future<void> setTheme(AppThemeMode themeMode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String themeModeString = _appThemeModeToString(themeMode);
    await prefs.setString(_themeKey, themeModeString);
    state = _appThemeModeToThemeMode(themeMode);
  }
  
  AppThemeMode get currentAppThemeMode {
    return _themeModeToAppThemeMode(state);
  }
  
  ThemeMode _stringToThemeMode(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
  
  String _appThemeModeToString(AppThemeMode appThemeMode) {
    switch (appThemeMode) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }
  
  ThemeMode _appThemeModeToThemeMode(AppThemeMode appThemeMode) {
    switch (appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
  
  AppThemeMode _themeModeToAppThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
      case ThemeMode.system:
        return AppThemeMode.system;
    }
  }
}

final StateNotifierProvider<ThemeNotifier, ThemeMode> themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((StateNotifierProviderRef<ThemeNotifier, ThemeMode> ref) {
  return ThemeNotifier();
});
