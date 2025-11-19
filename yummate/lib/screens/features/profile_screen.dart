import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:yummate/core/widgets/app_drawer.dart';
import 'package:yummate/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  // accept user id; if null, will use currentUser
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
      // not logged in
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
        // fallback: populate basic info from FirebaseAuth
        setState(() {
          _userData = {
            'name': authUser?.displayName ?? (authUser?.email?.split('@')[0] ?? 'Foodie'),
            'email': authUser?.email ?? '',
            'phone': '',
            'username': dataOrDefault(authUser?.email),
          };
          _loading = false;
        });
      }
    } catch (e) {
      print("Profile load error: $e");
      setState(() {
        _userData = null;
        _loading = false;
      });
    }
  }

  String dataOrDefault(String? email) {
    if (email == null) return '';
    return email.split('@')[0];
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _userData?['name'] ?? FirebaseAuth.instance.currentUser?.displayName ?? 'Foodie';
    final email = _userData?['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';

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
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header with gradient and avatar
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFEF6C00)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 6),
                                  Text(email, style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Get.snackbar('Edit', 'Edit profile coming soon');
                              },
                              icon: const Icon(Icons.edit, color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Stats row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatCard('Saved', '0'),
                                _buildStatCard('Recipes', '3'),
                                _buildStatCard('Ingredients', '${_userData?['ingredients']?.length ?? 0}'),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  children: [
                                    _buildInfoRow("Username", _userData!['username'] ?? ""),
                                    const Divider(),
                                    _buildInfoRow("Phone", _userData!['phone'] ?? ""),
                                    const Divider(),
                                    _buildInfoRow("UID", _uid ?? ""),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            ElevatedButton.icon(
                              onPressed: () {
                                Get.snackbar("Coming soon", "Edit profile will be available later");
                              },
                              icon: const Icon(Icons.edit_rounded),
                              label: const Text("Edit Profile"),
                            ),

                            const SizedBox(height: 12),

                            OutlinedButton.icon(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                Get.offAll(() => LoginScreen());
                              },
                              icon: const Icon(Icons.logout_rounded, color: Colors.red),
                              label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      children: [
        Expanded(flex: 3, child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
        Expanded(
          flex: 5,
          child: Text(value.isNotEmpty ? value : "—", textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
