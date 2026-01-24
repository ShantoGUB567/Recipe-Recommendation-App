import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/additional_information/controller/additional_information_controller.dart';

class HealthInfoWidget extends StatelessWidget {
  const HealthInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdditionalInfoController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFFF6B35).withOpacity(0.05), Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Information',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF6B35),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add allergies, conditions & preferences',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Allergies Section
            _buildSectionHeader(
              icon: Icons.warning_amber_rounded,
              title: 'Allergies',
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.commonAllergies.map((allergy) {
                  final isSelected = controller.selectedAllergies.contains(
                    allergy,
                  );
                  return _buildHealthChip(
                    label: allergy,
                    isSelected: isSelected,
                    color: Colors.red,
                    onTap: () {
                      if (isSelected) {
                        controller.selectedAllergies.remove(allergy);
                      } else {
                        controller.selectedAllergies.add(allergy);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _buildCustomInput(
              controller: controller.allergiesController,
              hintText: 'Add custom allergy',
              onAdd: () {
                if (controller.allergiesController.text.isNotEmpty) {
                  controller.selectedAllergies.add(
                    controller.allergiesController.text,
                  );
                  controller.allergiesController.clear();
                }
              },
            ),
            const SizedBox(height: 12),
            Obx(
              () => _buildSelectedItems(
                items: controller.selectedAllergies.toList(),
                color: Colors.red,
                onRemove: (item) => controller.selectedAllergies.remove(item),
              ),
            ),

            const SizedBox(height: 28),

            // Medical Conditions Section
            _buildSectionHeader(
              icon: Icons.medical_services,
              title: 'Medical Conditions',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.commonMedicalConditions.map((condition) {
                  final isSelected = controller.selectedMedicalConditions
                      .contains(condition);
                  return _buildHealthChip(
                    label: condition,
                    isSelected: isSelected,
                    color: Colors.orange,
                    onTap: () {
                      if (isSelected) {
                        controller.selectedMedicalConditions.remove(condition);
                      } else {
                        controller.selectedMedicalConditions.add(condition);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _buildCustomInput(
              controller: controller.medicalController,
              hintText: 'Add custom condition',
              onAdd: () {
                if (controller.medicalController.text.isNotEmpty) {
                  controller.selectedMedicalConditions.add(
                    controller.medicalController.text,
                  );
                  controller.medicalController.clear();
                }
              },
            ),
            const SizedBox(height: 12),
            Obx(
              () => _buildSelectedItems(
                items: controller.selectedMedicalConditions.toList(),
                color: Colors.orange,
                onRemove: (item) =>
                    controller.selectedMedicalConditions.remove(item),
              ),
            ),

            const SizedBox(height: 28),

            // Spicy Level Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Colors.deepOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Spicy Level Preference',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final level = controller.spicyLevel.value;
                    final labels = [
                      'Mild',
                      'Medium',
                      'Hot',
                      'Very Hot',
                      'Extreme',
                    ];
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              labels[level - 1],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            Text(
                              '🌶️' * level,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 20,
                            ),
                            activeTrackColor: Colors.deepOrange,
                            inactiveTrackColor: Colors.deepOrange.withOpacity(
                              0.2,
                            ),
                            thumbColor: Colors.deepOrange,
                            overlayColor: Colors.deepOrange.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: level.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            onChanged: (value) =>
                                controller.spicyLevel.value = value.toInt(),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? color : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomInput({
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onAdd,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedItems({
    required List<String> items,
    required Color color,
    required Function(String) onRemove,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => onRemove(item),
                  child: Icon(Icons.close, size: 14, color: color),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
