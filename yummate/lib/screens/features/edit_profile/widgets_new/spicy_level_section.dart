import 'package:flutter/material.dart';

class SpicyLevelSection extends StatelessWidget {
  final int spicyLevel;
  final ValueChanged<int> onChanged;

  const SpicyLevelSection({
    super.key,
    required this.spicyLevel,
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
                    Icons.whatshot,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Spicy Level',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🌶️ Mild'),
                Text(
                  '$spicyLevel',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('🌶️🌶️🌶️ Very Hot'),
              ],
            ),
            Slider(
              value: spicyLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (value) => onChanged(value.toInt()),
            ),
          ],
        ),
      ),
    );
  }
}
