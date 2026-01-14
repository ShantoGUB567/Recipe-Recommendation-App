import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/core/theme/app_theme.dart';
import 'package:yummate/core/theme/theme_controller.dart';
import 'package:yummate/screens/onboarding/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yummate/services/session_service.dart';
import 'package:yummate/screens/features/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // If .env isn't bundled or fails to load, continue but log the error
    // so FirebaseOptions will still have values (may be empty).
    // This prevents the app from crashing during startup.
    // You should ensure .env is included in pubspec.yaml assets.
    // ignore: avoid_print
    print('Could not load .env file: $e');
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize session service
  await SessionService().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final sessionService = SessionService();
    final isLoggedIn = await sessionService.isLoggedIn();

    // Check if user is logged in via session
    if (isLoggedIn) {
      // Also verify with Firebase
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Fetch user name from Firebase Database
        final dbRef = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(currentUser.uid);
        final snapshot = await dbRef.get();
        String userName = 'User';
        if (snapshot.exists) {
          final userData = snapshot.value as Map<dynamic, dynamic>;
          userName = userData['name'] ?? userData['username'] ?? 'User';
        }
        return HomeScreen(userName: userName);
      } else {
        // Session says logged in but Firebase doesn't, clear session
        await sessionService.logout();
      }
    }

    return const OnboardingScreen();
  }

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

        home: FutureBuilder<Widget>(
          future: _getInitialScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return snapshot.data ?? const OnboardingScreen();
          },
        ),
      ),
    );
  }
}
