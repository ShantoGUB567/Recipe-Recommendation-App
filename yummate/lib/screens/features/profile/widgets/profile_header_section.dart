import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/edit_profile/screen/edit_profile_screen.dart';

class ProfileHeaderSection extends StatelessWidget {
  final String displayName;
  final String email;
  final String? uid;
  final Map<String, dynamic> userData;
  final VoidCallback onRefresh;

  const ProfileHeaderSection({
    super.key,
    required this.displayName,
    required this.email,
    this.uid,
    required this.userData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFB8C00), Color(0xFFEF6C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white,
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'Y',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF6C00),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Get.to(
                () => EditProfileScreen(
                  userData: userData,
                  uid: uid ?? '',
                ),
              )?.then((_) => onRefresh());
            },
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
