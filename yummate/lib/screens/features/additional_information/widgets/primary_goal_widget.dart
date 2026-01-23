import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/additional_information/controller/additional_information_controller.dart';

class PrimaryGoalWidget extends StatelessWidget {
  const PrimaryGoalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdditionalInfoController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('Primary Goal', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('What is your primary fitness goal?', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          ...controller.primaryGoals.map((goal) => Obx(() => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RadioListTile<String>(
              value: goal,
              groupValue: controller.selectedPrimaryGoal.value,
              onChanged: (value) => controller.selectedPrimaryGoal.value = value,
              title: Text(goal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ))).toList(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
