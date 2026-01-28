import 'package:flutter/material.dart';

class PrimaryGoalSection extends StatelessWidget {
  final String? selectedPrimaryGoal;
  final List<String> primaryGoals;
  final ValueChanged<String?> onChanged;

  const PrimaryGoalSection({
    super.key,
    this.selectedPrimaryGoal,
    required this.primaryGoals,
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
                    color: const Color(0xFFFFA726).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.flag_outlined,
                    color: Color(0xFFFFA726),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Primary Goal',
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
              children: primaryGoals.map((goal) {
                final isSelected = selectedPrimaryGoal == goal;
                return FilterChip(
                  label: Text(goal),
                  selected: isSelected,
                  onSelected: (selected) {
                    onChanged(selected ? goal : null);
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
