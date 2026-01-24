import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/auth/login_screen.dart';
import 'package:yummate/services/session_service.dart';

class ProfileActionButtons extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String uid;
  final VoidCallback onRefresh;

  const ProfileActionButtons({
    super.key,
    required this.userData,
    required this.uid,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ElevatedButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          await SessionService().logout();
          Get.offAll(() => LoginScreen());
        },
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text(
          'Sign Out',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }
}
