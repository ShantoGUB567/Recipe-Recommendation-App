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

    debugPrint("🔍 loginUser() called");
    debugPrint("📧 Email: $email");
    debugPrint("🔑 Password length: ${password.length}");

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email & password required");
      debugPrint("❌ Empty email or password");
      return;
    }

    try {
      debugPrint("📡 Attempting Firebase Login...");
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint("✅ Firebase Login Successful");
      debugPrint("👤 User UID: ${userCredential.user?.uid}");

      await sessionService.saveLoginSession(
        userId: userCredential.user!.uid,
        email: email,
      );
      debugPrint("💾 Login session saved");

      // Fetch name from Realtime Database
      final dbRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(userCredential.user!.uid);

      debugPrint("📡 Fetching user name from DB path: users/${userCredential.user!.uid}");

      final snapshot = await dbRef.get();
      String userName = 'User';

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        debugPrint("📥 User Data: $data");

        userName = data['name'] ?? data['username'] ?? 'User';
      } else {
        debugPrint("⚠️ User DB snapshot does not exist");
      }

      debugPrint("👤 Final userName: $userName");

      Get.offAll(() => HomeScreen(userName: userName));
      debugPrint("➡️ Navigated to HomeScreen");

      Get.snackbar("Success", "Login successful!");
    } catch (e) {
      debugPrint("❌ Login Failed: $e");
      Get.snackbar("Login Failed", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("📍 LoginScreen build() called");

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
            onPressed: () {
              debugPrint("🌓 Theme toggle pressed");
              themeController.toggleTheme();
            },
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
                  height: MediaQuery.of(context).size.width * 0.5 * (975 / 2025),
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Turn Ingredients into Magic",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
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
                  onPressed: () {
                    debugPrint("🔐 Forgot Password pressed");
                  },
                  child: const Text(
                    "Forgot Password?",
                  ),
                ),
              ),

              const SizedBox(height: 10),

              PrimaryButton(
                text: "Login",
                onPressed: () async {
                  debugPrint("▶️ Login button pressed");
                  await loginUser();
                },
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don’t have an account?"),
                  TextButton(
                    onPressed: () {
                      debugPrint("➡️ Going to SignupScreen");
                      Get.to(() => SignupScreen());
                    },
                    child: const Text("Sign Up"),
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
