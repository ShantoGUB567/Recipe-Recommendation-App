import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/core/theme/theme_controller.dart';
import 'package:yummate/core/widgets/custom_text_field.dart';
import 'package:yummate/core/widgets/primary_button.dart';
import 'package:yummate/screens/auth/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final ThemeController themeController = Get.find<ThemeController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
              // const SizedBox(height: 20),

              // App Logo
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
              const SizedBox(height: 6),
              Text(
                "Welcome back, foodie!",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.color!.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 40),

              // 🥞 Email TextField
              CustomTextField(
                hintText: "Email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_rounded,
              ),

              // 🍳 Password TextField
              CustomTextField(
                hintText: "Password",
                controller: passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_rounded,
              ),

              // Forgot Password
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

              // 🍕 Login Button
              PrimaryButton(
                text: "Login",
                onPressed: () {
                  // TODO: Implement login functionality
                  Get.snackbar(
                    "Login",
                    "Attempting to log in...",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),

              const SizedBox(height: 20),

              // Signup Text
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
                      // Navigate to signup screen
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
