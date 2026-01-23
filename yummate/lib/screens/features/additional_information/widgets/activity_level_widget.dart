import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/additional_information/controller/additional_information_controller.dart';

class ActivityLevelWidget extends StatelessWidget {
  const ActivityLevelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdditionalInfoController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('Activity Level', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('How active are you in your daily life?', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          ...controller.activityLevels.map((level) => Obx(() => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RadioListTile<String>(
              value: level,
              groupValue: controller.selectedActivityLevel.value,
              onChanged: (value) => controller.selectedActivityLevel.value = value,
              title: Text(level),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ))).toList(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
