import 'package:flutter/material.dart';

class MedicalConditionsSection extends StatelessWidget {
  final List<String> selectedMedicalConditions;
  final List<String> commonMedicalConditions;
  final TextEditingController medicalController;
  final VoidCallback onAddCondition;
  final ValueChanged<List<String>> onChanged;

  const MedicalConditionsSection({
    super.key,
    required this.selectedMedicalConditions,
    required this.commonMedicalConditions,
    required this.medicalController,
    required this.onAddCondition,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medical Conditions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              children: commonMedicalConditions.map((condition) {
                final isSelected =
                    selectedMedicalConditions.contains(condition);
                return FilterChip(
                  label: Text(condition),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updated = List<String>.from(
                      selectedMedicalConditions,
                    );
                    if (selected) {
                      updated.add(condition);
                    } else {
                      updated.remove(condition);
                    }
                    onChanged(updated);
                  },
                  backgroundColor: Colors.transparent,
                  selectedColor: Colors.amber.shade100,
                  side: BorderSide(
                    color: isSelected
                        ? Colors.amber.shade400
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
                    controller: medicalController,
                    decoration: InputDecoration(
                      hintText: 'Add custom condition',
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
                      onTap: onAddCondition,
                      borderRadius: BorderRadius.circular(8),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            if (selectedMedicalConditions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: selectedMedicalConditions.map((condition) {
                      return Chip(
                        label: Text(condition),
                        onDeleted: () {
                          final updated = List<String>.from(
                            selectedMedicalConditions,
                          );
                          updated.remove(condition);
                          onChanged(updated);
                        },
                        backgroundColor: Colors.amber.shade100,
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
