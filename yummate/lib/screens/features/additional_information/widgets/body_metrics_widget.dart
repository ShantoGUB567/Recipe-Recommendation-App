import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/additional_information/controller/additional_information_controller.dart';

class BodyMetricsWidget extends StatelessWidget {
  const BodyMetricsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdditionalInfoController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('Body Metrics', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Tell us about your physical characteristics', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          // Age
          TextField(
            controller: controller.ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.calendar_today),
            ),
          ),
          const SizedBox(height: 16),
          // Gender
          Obx(() => DropdownButtonFormField<String>(
            value: controller.selectedGender.value,
            items: controller.genderOptions.map((gender) => DropdownMenuItem(value: gender, child: Text(gender))).toList(),
            onChanged: (value) => controller.selectedGender.value = value,
            decoration: InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.person),
            ),
          )),
          const SizedBox(height: 16),
          // Height
          TextField(
            controller: controller.heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Height (cm)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.height),
            ),
          ),
          const SizedBox(height: 16),
          // Weight
          TextField(
            controller: controller.weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Weight (kg)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.scale),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
