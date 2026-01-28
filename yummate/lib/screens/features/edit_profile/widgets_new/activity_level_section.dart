import 'package:flutter/material.dart';

class ActivityLevelSection extends StatelessWidget {
  final String? selectedActivityLevel;
  final List<String> activityLevels;
  final ValueChanged<String?> onChanged;

  const ActivityLevelSection({
    super.key,
    this.selectedActivityLevel,
    required this.activityLevels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.directions_run,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Activity Level',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: activityLevels.map((level) {
                final isSelected = selectedActivityLevel == level;
                return FilterChip(
                  label: Text(level),
                  selected: isSelected,
                  onSelected: (selected) {
                    onChanged(selected ? level : null);
                  },
                  selectedColor:
                      const Color(0xFF7CB342).withValues(alpha: 0.2),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
