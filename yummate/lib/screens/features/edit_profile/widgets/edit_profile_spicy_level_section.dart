import 'package:flutter/material.dart';

class EditProfileSpicyLevelSection extends StatefulWidget {
  final int initialLevel;
  final Function(int) onLevelChanged;

  const EditProfileSpicyLevelSection({
    super.key,
    required this.initialLevel,
    required this.onLevelChanged,
  });

  @override
  State<EditProfileSpicyLevelSection> createState() =>
      _EditProfileSpicyLevelSectionState();
}

class _EditProfileSpicyLevelSectionState
    extends State<EditProfileSpicyLevelSection> {
  late int spicyLevel;

  @override
  void initState() {
    super.initState();
    spicyLevel = widget.initialLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spicy Level',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
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
              const SizedBox(height: 8),
              Slider(
                value: spicyLevel.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (value) {
                  setState(() => spicyLevel = value.toInt());
                  widget.onLevelChanged(spicyLevel);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
