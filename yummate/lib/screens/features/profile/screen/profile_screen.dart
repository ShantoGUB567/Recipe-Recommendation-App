import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:yummate/core/widgets/app_drawer.dart';
import 'package:yummate/core/widgets/bottom_nav_bar.dart';
import 'package:yummate/screens/features/profile/widgets/profile_header_section.dart';
import 'package:yummate/screens/features/profile/widgets/profile_stats_section.dart';
import 'package:yummate/screens/features/profile/widgets/profile_info_section.dart';
import 'package:yummate/screens/features/profile/widgets/profile_additional_info_section.dart';
import 'package:yummate/screens/features/profile/widgets/profile_action_buttons.dart';
import 'package:yummate/screens/features/profile/widgets/profile_achievements_section.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  Map<String, dynamic>? _userData;
  String? _uid;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);

    final authUser = FirebaseAuth.instance.currentUser;
    _uid = widget.userId ?? authUser?.uid;

    if (_uid == null) {
      setState(() {
        _userData = null;
        _loading = false;
      });
      return;
    }

    try {
      final snapshot = await _db.child('users/$_uid').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _userData = data;
          _loading = false;
        });
      } else {
        setState(() {
          _userData = {
            'name':
                authUser?.displayName ??
                (authUser?.email?.split('@')[0] ?? 'Foodie'),
            'email': authUser?.email ?? '',
            'phone': '',
            'username': _dataOrDefault(authUser?.email),
          };
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Profile load error: $e");
      setState(() {
        _userData = null;
        _loading = false;
      });
    }
  }

  String _dataOrDefault(String? email) {
    if (email == null) return '';
    return email.split('@')[0];
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        _userData?['name'] ??
        FirebaseAuth.instance.currentUser?.displayName ??
        'Foodie';
    final email =
        _userData?['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            onPressed: () {
              // Navigate to settings if needed
            },
            tooltip: "Settings",
          ),
        ],
      ),
      drawer: AppDrawer(userName: displayName, userEmail: email),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
            )
          : _userData == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No profile data found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFFFF6B35),
              onRefresh: () async {
                await _loadUser();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header
                    ProfileHeaderSection(
                      displayName: displayName,
                      email: email,
                      uid: _uid,
                      userData: _userData ?? {},
                      onRefresh: _loadUser,
                    ),

                    const SizedBox(height: 12),

                    // Stats
                    ProfileStatsSection(userData: _userData ?? {}),

                    const SizedBox(height: 12),

                    // Info
                    ProfileInfoSection(
                      userData: _userData ?? {},
                      uid: _uid ?? '',
                    ),

                    const SizedBox(height: 12),

                    // Additional Information
                    ProfileAdditionalInfoSection(uid: _uid ?? ''),

                    const SizedBox(height: 12),

                    // Achievements
                    ProfileAchievementsSection(
                      postsCount: (_userData?['posts'] as Map?)?.length ?? 0,
                      savedRecipesCount:
                          (_userData?['savedRecipes'] as Map?)?.length ?? 0,
                      memberSince: _userData?['createdAt'] != null
                          ? DateTime.tryParse(
                              _userData!['createdAt'].toString(),
                            )
                          : null,
                    ),

                    const SizedBox(height: 12),

                    // Action Buttons
                    ProfileActionButtons(
                      userData: _userData ?? {},
                      uid: _uid ?? '',
                      onRefresh: _loadUser,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}
