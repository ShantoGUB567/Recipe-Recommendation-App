import 'package:flutter/material.dart';

class DietaryPreferencesSection extends StatelessWidget {
  final List<String> selectedDietaryPreferences;
  final List<String> dietaryOptions;
  final ValueChanged<List<String>> onChanged;

  const DietaryPreferencesSection({
    super.key,
    required this.selectedDietaryPreferences,
    required this.dietaryOptions,
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
                    color: const Color(0xFF7CB342).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Color(0xFF7CB342),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Dietary Preferences',
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
              children: dietaryOptions.map((diet) {
                final isSelected =
                    selectedDietaryPreferences.contains(diet);
                return FilterChip(
                  label: Text(diet),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updated = List<String>.from(
                      selectedDietaryPreferences,
                    );
                    if (selected) {
                      updated.add(diet);
                    } else {
                      updated.remove(diet);
                    }
                    onChanged(updated);
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
