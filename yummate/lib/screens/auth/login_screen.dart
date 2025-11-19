import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/core/theme/theme_controller.dart';
import 'package:yummate/core/widgets/custom_text_field.dart';
import 'package:yummate/core/widgets/primary_button.dart';
import 'package:yummate/screens/auth/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yummate/screens/features/home_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final ThemeController themeController = Get.find<ThemeController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email & password required");
      return;
    }

    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // SUCCESS → Go to HomeScreen
      // Get.offAll(() => HomeScreen());

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
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo.jpg',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                "Yummate",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
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

                    final userCredential = await auth.signInWithEmailAndPassword(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );

                    final user = userCredential.user;

                    // displayName null hole email er first part use hobe
                    final String name =
                        user?.displayName ?? user?.email?.split('@')[0] ?? "Foodie";

                    Get.offAll(() => HomeScreen(userName: name));
                  } catch (e) {
                    Get.snackbar(
                      "Login Failed",
                      e.toString(),
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }
                // onPressed: loginUser,
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don’t have an account?",
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .color!
                          .withOpacity(0.7),
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
