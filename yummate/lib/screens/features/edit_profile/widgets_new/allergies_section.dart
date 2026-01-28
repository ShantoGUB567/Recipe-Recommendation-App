import 'package:flutter/material.dart';

class AllergiesSection extends StatelessWidget {
  final List<String> selectedAllergies;
  final List<String> commonAllergies;
  final TextEditingController allergiesController;
  final VoidCallback onAddAllergy;
  final ValueChanged<List<String>> onChanged;

  const AllergiesSection({
    super.key,
    required this.selectedAllergies,
    required this.commonAllergies,
    required this.allergiesController,
    required this.onAddAllergy,
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
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Allergies',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              children: commonAllergies.map((allergy) {
                final isSelected = selectedAllergies.contains(allergy);
                return FilterChip(
                  label: Text(allergy),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updated = List<String>.from(selectedAllergies);
                    if (selected) {
                      updated.add(allergy);
                    } else {
                      updated.remove(allergy);
                    }
                    onChanged(updated);
                  },
                  backgroundColor: Colors.transparent,
                  selectedColor: Colors.red.shade100,
                  side: BorderSide(
                    color: isSelected
                        ? Colors.red.shade300
                        : Colors.grey[400]!,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: allergiesController,
                    decoration: InputDecoration(
                      hintText: 'Add custom allergy',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7CB342),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onAddAllergy,
                      borderRadius: BorderRadius.circular(8),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            if (selectedAllergies.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: selectedAllergies.map((allergy) {
                      return Chip(
                        label: Text(allergy),
                        onDeleted: () {
                          final updated = List<String>.from(
                            selectedAllergies,
                          );
                          updated.remove(allergy);
                          onChanged(updated);
                        },
                        backgroundColor: Colors.red.shade100,
                      );
                    }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
