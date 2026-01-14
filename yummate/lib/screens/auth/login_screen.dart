import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/core/theme/theme_controller.dart';
import 'package:yummate/core/widgets/custom_text_field.dart';
import 'package:yummate/core/widgets/primary_button.dart';
import 'package:yummate/screens/auth/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:yummate/screens/features/home_screen.dart';
import 'package:yummate/services/session_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final ThemeController themeController = Get.find<ThemeController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final SessionService sessionService = SessionService();

  Future<void> loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email & password required");
      return;
    }

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save login session
      await sessionService.saveLoginSession(
        userId: userCredential.user!.uid,
        email: email,
      );

      // Fetch user name from Firebase Database
      final dbRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(userCredential.user!.uid);
      final snapshot = await dbRef.get();
      String userName = 'User';
      if (snapshot.exists) {
        final userData = snapshot.value as Map<dynamic, dynamic>;
        userName = userData['name'] ?? userData['username'] ?? 'User';
      }

      // SUCCESS → Go to HomeScreen
      Get.offAll(() => HomeScreen(userName: userName));

      Get.snackbar("Success", "Login successful!");
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              themeController.isDarkMode.value
                  ? Icons.wb_sunny_rounded
                  : Icons.nightlight_round_rounded,
            ),
            onPressed: themeController.toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).size.width * 0.5,
                  height:
                      MediaQuery.of(context).size.width * 0.5 * (975 / 2025),
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Turn Ingredients into Magic",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              CustomTextField(
                hintText: "Email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_rounded,
              ),

              CustomTextField(
                hintText: "Password",
                controller: passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_rounded,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              PrimaryButton(
                text: "Login",
                onPressed: () async {
                  try {
                    final auth = FirebaseAuth.instance;

                    final userCredential = await auth
                        .signInWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );

                    final user = userCredential.user;

                    // displayName null hole email er first part use hobe
                    final String name =
                        user?.displayName ??
                        user?.email?.split('@')[0] ??
                        "Foodie";

                    Get.offAll(() => HomeScreen(userName: name));
                  } catch (e) {
                    Get.snackbar(
                      "Login Failed",
                      e.toString(),
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                // onPressed: loginUser,
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don’t have an account?",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.color!.withOpacity(0.7),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(() => SignupScreen());
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
