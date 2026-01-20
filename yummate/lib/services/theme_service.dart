import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxController {
  static const String themeKey = 'app_theme_mode';
  
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(themeKey);
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'dark':
          themeMode.value = ThemeMode.dark;
          break;
        case 'light':
          themeMode.value = ThemeMode.light;
          break;
        default:
          themeMode.value = ThemeMode.system;
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    
    String modeString = 'system';
    switch (mode) {
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeKey, modeString);
    Get.changeThemeMode(mode);
  }

  bool isDarkMode() {
    if (themeMode.value == ThemeMode.dark) {
      return true;
    } else if (themeMode.value == ThemeMode.light) {
      return false;
    } else {
      // System mode - check brightness
      return MediaQuery.of(Get.context!).platformBrightness == Brightness.dark;
    }
  }
}
