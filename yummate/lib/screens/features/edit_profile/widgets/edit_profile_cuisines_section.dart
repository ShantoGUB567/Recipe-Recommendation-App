import 'package:flutter/material.dart';

class EditProfileCuisinesSection extends StatefulWidget {
  final List<String> initialCuisines;
  final List<String> cuisineOptions;
  final Function(List<String>) onCuisinesChanged;

  const EditProfileCuisinesSection({
    super.key,
    required this.initialCuisines,
    required this.cuisineOptions,
    required this.onCuisinesChanged,
  });

  @override
  State<EditProfileCuisinesSection> createState() =>
      _EditProfileCuisinesSectionState();
}

class _EditProfileCuisinesSectionState
    extends State<EditProfileCuisinesSection> {
  late List<String> selectedCuisines;

  @override
  void initState() {
    super.initState();
    selectedCuisines = List<String>.from(widget.initialCuisines);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Favorite Cuisines',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.cuisineOptions.map((cuisine) {
            final isSelected = selectedCuisines.contains(cuisine);
            return FilterChip(
              label: Text(cuisine),
              selected: isSelected,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    selectedCuisines.add(cuisine);
                  } else {
                    selectedCuisines.remove(cuisine);
                  }
                  widget.onCuisinesChanged(selectedCuisines);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
