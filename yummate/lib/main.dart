import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/core/theme/app_theme.dart';
import 'package:yummate/core/theme/theme_controller.dart';
import 'package:yummate/screens/onboarding/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Put ThemeController into GetX dependency system
    final ThemeController themeController = Get.put(ThemeController());

    return Obx(
      () => GetMaterialApp(
        title: 'Yummate',
        debugShowCheckedModeBanner: false,

        // Use GetX reactive theme switching
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,

        home: const OnboardingScreen(),
      ),
    );
  }
}
