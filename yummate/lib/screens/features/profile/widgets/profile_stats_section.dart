import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileStatsSection extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileStatsSection({super.key, required this.userData});

  @override
  State<ProfileStatsSection> createState() => _ProfileStatsSectionState();
}

class _ProfileStatsSectionState extends State<ProfileStatsSection> {
  int _savedRecipesCount = 0;
  int _communityPostsCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final db = FirebaseDatabase.instance.ref();

      // Get saved recipes count
      final savedRecipesSnapshot = await db
          .child('users')
          .child(user.uid)
          .child('saved_recipes')
          .get();

      int savedCount = 0;
      if (savedRecipesSnapshot.exists) {
        final data = savedRecipesSnapshot.value as Map;
        savedCount = data.length;
      }

      // Get community posts count
      final postsSnapshot = await db.child('posts').get();
      int postsCount = 0;
      if (postsSnapshot.exists) {
        final data = Map<String, dynamic>.from(postsSnapshot.value as Map);
        // Count only posts by this user
        data.forEach((key, value) {
          final post = Map<String, dynamic>.from(value as Map);
          if (post['userId'] == user.uid) {
            postsCount++;
          }
        });
      }

      if (mounted) {
        setState(() {
          _savedRecipesCount = savedCount;
          _communityPostsCount = postsCount;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Saved',
              _loading ? '...' : '$_savedRecipesCount',
              Icons.bookmark,
              const Color(0xFFFF6B35),
            ),
          ),
          Container(width: 1, height: 50, color: Colors.grey.shade200),
          Expanded(
            child: _buildStatItem(
              'Posts',
              _loading ? '...' : '$_communityPostsCount',
              Icons.article,
              const Color(0xFFFF6B35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
