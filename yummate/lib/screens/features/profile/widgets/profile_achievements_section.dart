import 'package:flutter/material.dart';

class ProfileAchievementsSection extends StatelessWidget {
  final int postsCount;
  final int savedRecipesCount;
  final DateTime? memberSince;

  const ProfileAchievementsSection({
    Key? key,
    required this.postsCount,
    required this.savedRecipesCount,
    this.memberSince,
  }) : super(key: key);

  List<Map<String, dynamic>> _getAchievements() {
    List<Map<String, dynamic>> achievements = [];

    // Post-based achievements
    if (postsCount >= 1) {
      achievements.add({
        'icon': Icons.edit_note,
        'title': 'First Post',
        'description': 'Shared your first recipe',
        'color': Colors.blue,
      });
    }
    if (postsCount >= 10) {
      achievements.add({
        'icon': Icons.menu_book,
        'title': 'Recipe Contributor',
        'description': 'Shared 10+ recipes',
        'color': Colors.green,
      });
    }
    if (postsCount >= 50) {
      achievements.add({
        'icon': Icons.emoji_events,
        'title': 'Recipe Master',
        'description': 'Shared 50+ recipes',
        'color': Colors.orange,
      });
    }
    if (postsCount >= 100) {
      achievements.add({
        'icon': Icons.workspace_premium,
        'title': 'Top Contributor',
        'description': 'Shared 100+ recipes',
        'color': const Color(0xFFFF6B35),
      });
    }

    // Saved recipes achievements
    if (savedRecipesCount >= 10) {
      achievements.add({
        'icon': Icons.bookmark,
        'title': 'Recipe Collector',
        'description': 'Saved 10+ recipes',
        'color': Colors.purple,
      });
    }
    if (savedRecipesCount >= 50) {
      achievements.add({
        'icon': Icons.bookmarks,
        'title': 'Recipe Enthusiast',
        'description': 'Saved 50+ recipes',
        'color': Colors.deepPurple,
      });
    }

    // Time-based achievements
    if (memberSince != null) {
      final daysSinceMember = DateTime.now().difference(memberSince!).inDays;

      if (daysSinceMember >= 30) {
        achievements.add({
          'icon': Icons.calendar_month,
          'title': 'Monthly Member',
          'description': 'Active for 1+ month',
          'color': Colors.teal,
        });
      }
      if (daysSinceMember >= 365) {
        achievements.add({
          'icon': Icons.cake,
          'title': 'Yearly Member',
          'description': 'Active for 1+ year',
          'color': Colors.amber,
        });
      }
    }

    return achievements;
  }

  @override
  Widget build(BuildContext context) {
    final achievements = _getAchievements();

    if (achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFFF6B35),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Achievements",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${achievements.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Achievements Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: achievements.map((achievement) {
                return _buildAchievementBadge(
                  icon: achievement['icon'] as IconData,
                  title: achievement['title'] as String,
                  description: achievement['description'] as String,
                  color: achievement['color'] as Color,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
