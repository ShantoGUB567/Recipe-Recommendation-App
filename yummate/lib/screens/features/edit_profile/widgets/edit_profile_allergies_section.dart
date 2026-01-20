import 'package:flutter/material.dart';

class EditProfileAllergiesSection extends StatefulWidget {
  final List<String> initialAllergies;
  final List<String> allergyOptions;
  final Function(List<String>) onAllergiesChanged;

  const EditProfileAllergiesSection({
    super.key,
    required this.initialAllergies,
    required this.allergyOptions,
    required this.onAllergiesChanged,
  });

  @override
  State<EditProfileAllergiesSection> createState() =>
      _EditProfileAllergiesSectionState();
}

class _EditProfileAllergiesSectionState
    extends State<EditProfileAllergiesSection> {
  late List<String> selectedAllergies;

  @override
  void initState() {
    super.initState();
    selectedAllergies = List<String>.from(widget.initialAllergies);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Allergies',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.allergyOptions.map((allergy) {
            final isSelected = selectedAllergies.contains(allergy);
            return FilterChip(
              label: Text(allergy),
              selected: isSelected,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    selectedAllergies.add(allergy);
                  } else {
                    selectedAllergies.remove(allergy);
                  }
                  widget.onAllergiesChanged(selectedAllergies);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
