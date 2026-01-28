import 'package:flutter/material.dart';

class CuisinesSection extends StatelessWidget {
  final List<String> selectedCuisines;
  final List<String> commonCuisines;
  final TextEditingController cuisinesController;
  final VoidCallback onAddCuisine;
  final ValueChanged<List<String>> onChanged;

  const CuisinesSection({
    super.key,
    required this.selectedCuisines,
    required this.commonCuisines,
    required this.cuisinesController,
    required this.onAddCuisine,
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
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.public,
                    color: Color(0xFFFF6B35),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Favorite Cuisines',
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
              children: commonCuisines.map((cuisine) {
                final isSelected = selectedCuisines.contains(cuisine);
                return FilterChip(
                  label: Text(cuisine),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updated = List<String>.from(selectedCuisines);
                    if (selected) {
                      updated.add(cuisine);
                    } else {
                      updated.remove(cuisine);
                    }
                    onChanged(updated);
                  },
                  backgroundColor: Colors.transparent,
                  selectedColor:
                      const Color(0xFF7CB342).withValues(alpha: 0.2),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF7CB342)
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
                    controller: cuisinesController,
                    decoration: InputDecoration(
                      hintText: 'Add custom cuisine',
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
                      onTap: onAddCuisine,
                      borderRadius: BorderRadius.circular(8),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            if (selectedCuisines.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: selectedCuisines.map((cuisine) {
                      return Chip(
                        label: Text(cuisine),
                        onDeleted: () {
                          final updated = List<String>.from(
                            selectedCuisines,
                          );
                          updated.remove(cuisine);
                          onChanged(updated);
                        },
                        backgroundColor: const Color(0xFF7CB342)
                            .withValues(alpha: 0.2),
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
