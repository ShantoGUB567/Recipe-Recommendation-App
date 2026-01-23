import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/additional_information/controller/additional_information_controller.dart';

class HealthInfoWidget extends StatelessWidget {
  const HealthInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdditionalInfoController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('Health Information', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Add any allergies, medical conditions & spicy level', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),

          // Allergies
          Text('Allergies', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.commonAllergies.map((allergy) {
              final isSelected = controller.selectedAllergies.contains(allergy);
              return FilterChip(
                label: Text(allergy),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    controller.selectedAllergies.add(allergy);
                  } else {
                    controller.selectedAllergies.remove(allergy);
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
                  controller: controller.allergiesController,
                  decoration: InputDecoration(
                    hintText: 'Add custom allergy',
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
                      if (controller.allergiesController.text.isNotEmpty) {
                        controller.selectedAllergies.add(controller.allergiesController.text);
                        controller.allergiesController.clear();
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
          Obx(() => controller.selectedAllergies.isNotEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selected:', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.selectedAllergies.map((allergy) => Chip(
                  label: Text(allergy),
                  onDeleted: () => controller.selectedAllergies.remove(allergy),
                  backgroundColor: const Color(0xFF7CB342).withOpacity(0.2),
                  deleteIcon: const Icon(Icons.close, size: 18),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ) : const SizedBox.shrink()),

          // Medical Conditions
          Text('Medical Conditions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.commonMedicalConditions.map((condition) {
              final isSelected = controller.selectedMedicalConditions.contains(condition);
              return FilterChip(
                label: Text(condition),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    controller.selectedMedicalConditions.add(condition);
                  } else {
                    controller.selectedMedicalConditions.remove(condition);
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
                  controller: controller.medicalController,
                  decoration: InputDecoration(
                    hintText: 'Add custom condition',
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
                      if (controller.medicalController.text.isNotEmpty) {
                        controller.selectedMedicalConditions.add(controller.medicalController.text);
                        controller.medicalController.clear();
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
          Obx(() => controller.selectedMedicalConditions.isNotEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selected:', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.selectedMedicalConditions.map((condition) => Chip(
                  label: Text(condition),
                  onDeleted: () => controller.selectedMedicalConditions.remove(condition),
                  backgroundColor: const Color(0xFF7CB342).withOpacity(0.2),
                  deleteIcon: const Icon(Icons.close, size: 18),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ) : const SizedBox.shrink()),

          // Spicy Level
          const SizedBox(height: 16),
          const Text('🌶️ Spicy Level', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
            child: Obx(() => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🌶️ Mild'),
                    Text('${controller.spicyLevel.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('🌶️🌶️🌶️ Very Hot'),
                  ],
                ),
                Slider(
                  value: controller.spicyLevel.value.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) => controller.spicyLevel.value = value.toInt(),
                ),
              ],
            )),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
