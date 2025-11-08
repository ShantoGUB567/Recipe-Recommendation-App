import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/core/theme/theme_controller.dart';
import 'package:yummate/core/widgets/custom_text_field.dart';
import 'package:yummate/core/widgets/primary_button.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final ThemeController themeController = Get.find<ThemeController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
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
              const SizedBox(height: 20),

              // 🍔 App Logo or Emoji
              CircleAvatar(
                radius: 40,
                backgroundColor: isDark ? Colors.orange[200] : Colors.orange[50],
                child: const Text(
                  "🍴",
                  style: TextStyle(fontSize: 36),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Join Yummate and start cooking!",
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .color!
                      .withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 30),

              // 🥞 Full Name
              CustomTextField(
                hintText: "Full Name",
                controller: nameController,
                prefixIcon: Icons.person_rounded,
              ),

              // Username
              CustomTextField(
                hintText: "Username",
                controller: usernameController,
                prefixIcon: Icons.account_circle_rounded,
              ),

              // Email
              CustomTextField(
                hintText: "Email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_rounded,
              ),

              // Phone
              CustomTextField(
                hintText: "Phone",
                controller: phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_rounded,
              ),

              // Password
              CustomTextField(
                hintText: "Password",
                controller: passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_rounded,
              ),

              // Confirm Password
              CustomTextField(
                hintText: "Confirm Password",
                controller: confirmPasswordController,
                isPassword: true,
                prefixIcon: Icons.lock_rounded,
              ),

              const SizedBox(height: 10),

              // 🍕 Create Account Button
              PrimaryButton(
                text: "Create Account",
                onPressed: () {
                  // TODO: Implement signup functionality
                  Get.snackbar(
                    "Signup",
                    "Creating your account...",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),

              const SizedBox(height: 20),

              // Login Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
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
                      // Navigate back to login screen
                      Get.back();
                    },
                    child: const Text(
                      "Login",
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
