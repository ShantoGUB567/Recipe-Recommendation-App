import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:yummate/core/widgets/app_drawer.dart';
import 'package:yummate/core/widgets/bottom_nav_bar.dart';
import 'package:yummate/screens/features/profile/widgets/profile_header_section.dart';
import 'package:yummate/screens/features/profile/widgets/profile_stats_section.dart';
import 'package:yummate/screens/features/profile/widgets/profile_info_section.dart';
import 'package:yummate/screens/features/profile/widgets/profile_preferences_section.dart';
import 'package:yummate/screens/features/profile/widgets/profile_action_buttons.dart';

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
      appBar: AppBar(
        title: const Text("Profile"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadUser,
            tooltip: "Refresh",
          ),
        ],
      ),
      drawer: AppDrawer(userName: displayName, userEmail: email),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("No profile data found."),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadUser,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
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

                      // Stats
                      ProfileStatsSection(userData: _userData ?? {}),

                      const SizedBox(height: 18),

                      // Info
                      ProfileInfoSection(
                        userData: _userData ?? {},
                        uid: _uid ?? '',
                      ),

                      const SizedBox(height: 18),

                      // Preferences
                      ProfilePreferencesSection(userData: _userData ?? {}),

                      const SizedBox(height: 32),

                      // Action Buttons
                      ProfileActionButtons(
                        userData: _userData ?? {},
                        uid: _uid ?? '',
                        onRefresh: _loadUser,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}
