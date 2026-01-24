import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:yummate/screens/auth/login_screen.dart';
import 'package:yummate/screens/features/profile_screen.dart';
import 'package:yummate/screens/features/edit_profile_screen.dart';
import 'package:yummate/screens/features/home_screen.dart';
import 'package:yummate/screens/features/settings_screen.dart';
import 'package:yummate/screens/features/about_screen.dart';
import 'package:yummate/screens/features/saved_recipes_screen.dart';
import 'package:yummate/screens/features/saved_posts_screen.dart';
import 'package:yummate/screens/features/community_screen.dart';
import 'package:yummate/screens/features/recipe_history_screen.dart';
import 'package:yummate/services/session_service.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String? userEmail;

  const AppDrawer({super.key, required this.userName, this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Top gradient header with avatar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 42,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFB8C00), Color(0xFFEF6C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'Y',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF6C00),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid != null) {
                      final DatabaseReference db = FirebaseDatabase.instance
                          .ref();
                      final snapshot = await db.child('users').child(uid).get();
                      if (snapshot.exists) {
                        Get.to(
                          () => EditProfileScreen(
                            userData: Map<String, dynamic>.from(
                              snapshot.value as Map,
                            ),
                            uid: uid,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 12),
                _buildListTile(context, Icons.home_rounded, 'Home', () {
                  // go to home and close drawer
                  Get.back();
                  Get.offAll(() => HomeScreen(userName: userName));
                }),
                _buildListTile(
                  context,
                  Icons.person_outline_rounded,
                  'Profile',
                  () {
                    Get.back();
                    Get.to(
                      () => ProfileScreen(
                        userId: FirebaseAuth.instance.currentUser?.uid,
                      ),
                    );
                  },
                ),
                _buildListTile(
                  context,
                  Icons.bookmark_rounded,
                  'Saved Recipes',
                  () {
                    Get.back();
                    Get.to(() => SavedRecipesScreen());
                  },
                ),
                _buildListTile(
                  context,
                  Icons.bookmark_outline,
                  'Saved Posts',
                  () {
                    Get.back();
                    Get.to(() => SavedPostsScreen());
                  },
                ),
                _buildListTile(context, Icons.history, 'Recipe History', () {
                  Get.back();
                  Get.to(() => const SavedRecipeSessionsScreen());
                }),
                // replaced 'My Ingredients' with Community feature
                _buildListTile(context, Icons.group_rounded, 'Community', () {
                  Get.back();
                  Get.to(() => CommunityScreen());
                }),
                _buildListTile(context, Icons.settings_rounded, 'Settings', () {
                  Get.back();
                  Get.to(() => SettingsScreen());
                }),
                _buildListTile(
                  context,
                  Icons.info_outline_rounded,
                  'About Yummate',
                  () {
                    Get.back();
                    Get.to(() => AboutScreen());
                  },
                ),
              ],
            ),
          ),

          // Logout (sticky bottom)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListTile(
              tileColor: Colors.red.withValues(alpha: 0.06),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                await SessionService().logout();
                Get.offAll(() => LoginScreen());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepOrange.withValues(alpha: 0.12),
        child: Icon(icon, color: Colors.deepOrange),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
