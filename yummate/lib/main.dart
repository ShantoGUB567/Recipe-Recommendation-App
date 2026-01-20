import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:yummate/core/theme/app_theme.dart';
import 'package:yummate/services/theme_service.dart';
import 'package:yummate/screens/onboarding/onboarding_screen.dart';
import 'package:yummate/screens/features/home_screen.dart';
import 'package:yummate/services/session_service.dart';

import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

void _configEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..maskColor = Colors.black.withValues(alpha: .5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Could not load .env file: $e');
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SessionService().init();

  _configEasyLoading();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Get.put(ThemeService());

    return Obx(
      () => GetMaterialApp(
        title: 'Yummate',
        debugShowCheckedModeBanner: false,

        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeService.themeMode.value,

        // NEW: Use initialRoute instead of FutureBuilder
        initialRoute: '/splash',
        getPages: [
          GetPage(name: '/splash', page: () => const SplashRouter()),
          GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
          GetPage(name: '/home', page: () => const HomeScreen(userName: "")),
        ],
        builder: EasyLoading.init(),
      ),
    );
  }
}

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _decision();
  }

  Future<void> _decision() async {
    final sessionService = SessionService();
    final isLoggedIn = await sessionService.isLoggedIn();

    if (isLoggedIn) {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // fetch name
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

        Future.delayed(const Duration(milliseconds: 300), () {
          Get.offAll(() => HomeScreen(userName: userName));
        });
        return;
      }

      // Session says logged in but Firebase null → Logout
      await sessionService.logout();
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      Get.offAllNamed('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
