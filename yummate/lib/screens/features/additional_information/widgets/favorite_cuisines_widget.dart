import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/additional_information/controller/additional_information_controller.dart';

class FavoriteCuisinesWidget extends StatelessWidget {
  const FavoriteCuisinesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdditionalInfoController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('Favorite Cuisines', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Select cuisines you enjoy', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.commonCuisines.map((cuisine) {
              final isSelected = controller.selectedCuisines.contains(cuisine);
              return FilterChip(
                label: Text(cuisine),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    controller.selectedCuisines.add(cuisine);
                  } else {
                    controller.selectedCuisines.remove(cuisine);
                  }
                },
                backgroundColor: Colors.transparent,
                selectedColor: const Color(0xFF7CB342).withOpacity(0.2),
                side: BorderSide(color: isSelected ? const Color(0xFF7CB342) : Colors.grey[400]!),
              );
            }).toList(),
          )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.cuisinesController,
                  decoration: InputDecoration(
                    hintText: 'Add custom cuisine',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(color: const Color(0xFF7CB342), borderRadius: BorderRadius.circular(8)),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (controller.cuisinesController.text.isNotEmpty) {
                        controller.selectedCuisines.add(controller.cuisinesController.text);
                        controller.cuisinesController.clear();
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => controller.selectedCuisines.isNotEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selected:', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.selectedCuisines.map((cuisine) => Chip(
                  label: Text(cuisine),
                  onDeleted: () => controller.selectedCuisines.remove(cuisine),
                  backgroundColor: const Color(0xFF7CB342).withOpacity(0.2),
                  deleteIcon: const Icon(Icons.close, size: 18),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ) : const SizedBox.shrink()),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
