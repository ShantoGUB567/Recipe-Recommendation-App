import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// 🌗 Controls the Theme Mode using GetX
class ThemeController extends GetxController {
  RxBool isDarkMode = false.obs;

  ThemeData get currentTheme =>
      isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeTheme(isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme);
  }
}
