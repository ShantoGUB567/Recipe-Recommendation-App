import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/additional_information/controller/additional_information_controller.dart';

class DietaryPreferencesWidget extends StatelessWidget {
  const DietaryPreferencesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdditionalInfoController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('Dietary Preferences', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Select one or more dietary preferences', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.dietaryOptions.map((diet) {
              final isSelected = controller.selectedDietaryPreferences.contains(diet);
              return FilterChip(
                label: Text(diet),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    controller.selectedDietaryPreferences.add(diet);
                  } else {
                    controller.selectedDietaryPreferences.remove(diet);
                  }
                },
                backgroundColor: Colors.transparent,
                selectedColor: const Color(0xFF7CB342).withOpacity(0.2),
                side: BorderSide(color: isSelected ? const Color(0xFF7CB342) : Colors.grey[400]!),
              );
            }).toList(),
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
