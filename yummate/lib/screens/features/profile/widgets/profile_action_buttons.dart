import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/auth/login_screen.dart';
import 'package:yummate/screens/features/edit_profile/screen/edit_profile_screen.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Get.to(
                () => EditProfileScreen(
                  userData: userData,
                  uid: uid,
                ),
              )?.then((_) => onRefresh());
            },
            icon: const Icon(Icons.edit_rounded),
            label: const Text("Edit Profile"),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await SessionService().logout();
              Get.offAll(() => LoginScreen());
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            label: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
