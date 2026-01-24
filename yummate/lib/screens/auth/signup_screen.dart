import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:yummate/services/theme_service.dart';
import 'package:yummate/core/widgets/custom_text_field.dart';
import 'package:yummate/core/widgets/primary_button.dart';
import 'package:yummate/screens/auth/login_screen.dart';
import 'package:yummate/services/session_service.dart';
import 'package:yummate/screens/features/home/screen/home_screen.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final ThemeService themeService = Get.find<ThemeService>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(
    "users",
  );
  final SessionService sessionService = SessionService();

  Future<void> signupUser() async {
    String name = nameController.text.trim();
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required!",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        "Error",
        "Passwords do not match!",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // ✅ Create user in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // ✅ Save additional user data in Realtime DB
      await dbRef.child(uid).set({
        "name": name,
        "username": username,
        "email": email,
        "phone": phone,
        "uid": uid,
      });

      // ✅ Save login session
      await sessionService.saveLoginSession(userId: uid, email: email);

      Get.snackbar(
        "Success",
        "Account created successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
      );

      // Go directly to HomeScreen after signup
      Get.offAll(() => HomeScreen(userName: name));
    } on FirebaseAuthException catch (e) {
      // Show structured auth error code and message
      Get.snackbar(
        "Signup Failed",
        "${e.code}: ${e.message}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } catch (e) {
      Get.snackbar(
        "Signup Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
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
            icon: Obx(
              () => Icon(
                themeService.themeMode.value == ThemeMode.dark
                    ? Icons.wb_sunny_rounded
                    : Icons.nightlight_round_rounded,
              ),
            ),
            onPressed: () {
              final newMode = themeService.themeMode.value == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              themeService.setThemeMode(newMode);
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
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).size.width * 0.5,
                  height:
                      MediaQuery.of(context).size.width * 0.5 * (975 / 2025),
                  fit: BoxFit.contain,
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
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.color!.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 30),

              CustomTextField(
                hintText: "Full Name",
                controller: nameController,
                prefixIcon: Icons.person_rounded,
              ),

              CustomTextField(
                hintText: "Username",
                controller: usernameController,
                prefixIcon: Icons.account_circle_rounded,
              ),

              CustomTextField(
                hintText: "Email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_rounded,
              ),

              CustomTextField(
                hintText: "Phone",
                controller: phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_rounded,
              ),

              CustomTextField(
                hintText: "Password",
                controller: passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_rounded,
              ),

              CustomTextField(
                hintText: "Confirm Password",
                controller: confirmPasswordController,
                isPassword: true,
                prefixIcon: Icons.lock_rounded,
              ),

              const SizedBox(height: 10),

              PrimaryButton(
                text: "Create Account",
                onPressed: signupUser, // ⬅ Firebase Signup Function
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.color!.withValues(alpha: 0.7),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => LoginScreen()),
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

// Variant: debugAndroidTest
// Config: debug
// Store: C:\Users\alsha\.android\debug.keystore
// Alias: AndroidDebugKey
// MD5: A0:D2:3B:08:29:06:02:20:50:0B:03:53:65:7B:01:3B
// SHA1: A7:EA:70:22:5D:1F:93:E2:61:E4:2E:75:CD:6C:78:43:AF:68:1C:8E
// SHA-256: 02:BF:B5:9C:DD:94:DB:EE:41:5B:F0:CF:41:8D:56:9D:5C:60:F4:43:2E:C9:71:59:E7:DF:D4:84:95:46:C3:9A
// Valid until: Tuesday, July 7, 2054
