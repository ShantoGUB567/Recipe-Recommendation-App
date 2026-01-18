import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yummate/core/widgets/app_drawer.dart';
import 'package:yummate/core/widgets/bottom_nav_bar.dart';
import 'package:yummate/models/user_profile_model.dart';
import 'package:yummate/screens/auth/login_screen.dart';
import 'package:yummate/screens/features/edit_profile_screen.dart';
import 'package:yummate/services/session_service.dart';

class ProfileScreen extends StatefulWidget {
  // accept user id; if null, will use currentUser
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  UserProfile? _userProfile;
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
        _userProfile = null;
        _loading = false;
      });
      return;
    }

    try {
      // Try to load user profile from Firestore first
      final profileDoc = await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(_uid)
          .get();

      if (profileDoc.exists) {
        final profile = UserProfile.fromJson(profileDoc.data()!);
        setState(() {
          _userProfile = profile;
          _loading = false;
        });
        return;
      }

      // Fallback to Realtime Database
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
            'username': dataOrDefault(authUser?.email),
          };
          _loading = false;
        });
      }
    } catch (e) {
      print("Profile load error: $e");
      setState(() {
        _userData = null;
        _userProfile = null;
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
    // If user profile exists, show the new profile display
    if (_userProfile != null) {
      return _buildUserProfileView();
    }

    // Otherwise use the old profile view
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
                  // Header with gradient and avatar
                  Container(
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
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : 'Y',
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
                                userData: _userData ?? {},
                                uid: _uid ?? '',
                              ),
                            )?.then((_) => _loadUser());
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
                            _buildStatCard(
                              'Posts',
                              '${_userData?['ingredients']?.length ?? 0}',
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  "Username",
                                  _userData!['username'] ?? "",
                                ),
                                const Divider(),
                                _buildInfoRow(
                                  "Phone",
                                  _userData!['phone'] ?? "",
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Preferences',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Expanded(
                                      flex: 2,
                                      child: Text('Spicy Level'),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            Icons.local_fire_department,
                                            size: 16,
                                            color:
                                                i <
                                                    (_userData?['spicy_level'] ??
                                                        2)
                                                ? Colors.orange
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                const SizedBox(height: 8),
                                const Text(
                                  'Favorite Cuisines',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children:
                                      ((_userData?['favorite_cuisines']
                                                  as List?) ??
                                              [])
                                          .map<Widget>(
                                            (c) => Chip(label: Text(c)),
                                          )
                                          .toList(),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Allergies',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children:
                                      ((_userData?['allergies'] as List?) ?? [])
                                          .map<Widget>(
                                            (a) => Chip(
                                              label: Text(a),
                                              backgroundColor:
                                                  Colors.red.shade100,
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        ElevatedButton.icon(
                          onPressed: () {
                            Get.to(
                              () => EditProfileScreen(
                                userData: _userData ?? {},
                                uid: _uid ?? '',
                              ),
                            )?.then((_) => _loadUser());
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
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value.isNotEmpty ? value : "—",
            textAlign: TextAlign.right,
          ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // New user profile view builder
  Widget _buildUserProfileView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header with User Info
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  // Body Metrics Card
                  _buildSectionCard(
                    title: 'Body Metrics',
                    children: [
                      _buildUserInfoRow('Age', '${_userProfile!.age} years'),
                      _buildUserInfoRow('Gender', _userProfile!.gender),
                      _buildUserInfoRow('Height', '${_userProfile!.height} cm'),
                      _buildUserInfoRow('Weight', '${_userProfile!.weight} kg'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Health & Activity Card
                  _buildSectionCard(
                    title: 'Health & Activity',
                    children: [
                      _buildUserInfoRow(
                        'Activity Level',
                        _userProfile!.activityLevel,
                      ),
                      _buildUserInfoRow(
                        'Primary Goal',
                        _userProfile!.primaryGoal,
                      ),
                      _buildUserInfoRow(
                        'Daily Calorie Goal',
                        '${_userProfile!.calculateCalorieGoal()} kcal',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Dietary Preferences Card
                  _buildSectionCard(
                    title: 'Dietary Preferences',
                    children: [
                      Wrap(
                        spacing: 8,
                        children: _userProfile!.dietaryPreferences.map((diet) {
                          return Chip(
                            label: Text(diet),
                            backgroundColor:
                                const Color(0xFF7CB342).withOpacity(0.2),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Health Constraints Card
                  if (_userProfile!.allergies.isNotEmpty ||
                      _userProfile!.medicalConditions.isNotEmpty)
                    _buildSectionCard(
                      title: 'Health Constraints',
                      children: [
                        if (_userProfile!.allergies.isNotEmpty) ...[
                          _buildConstraintSection(
                            'Allergies',
                            _userProfile!.allergies,
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (_userProfile!.medicalConditions.isNotEmpty)
                          _buildConstraintSection(
                            'Medical Conditions',
                            _userProfile!.medicalConditions,
                          ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Get.to(() => EditProfileScreen(
                          userProfile: _userProfile,
                          userData: {},
                          uid: _uid ?? '',
                        ));
                        if (result == true) {
                          _loadUser();
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7CB342),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7CB342).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7CB342).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF7CB342),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Profile Complete',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Last updated: ${_userProfile!.updatedAt.toString().split('.')[0]}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildConstraintSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return Chip(
              label: Text(item),
              backgroundColor: Colors.red.withOpacity(0.2),
              labelStyle: const TextStyle(color: Colors.red),
            );
          }).toList(),
        ),
      ],
    );
  }
}
