import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/additional_information/controller/additional_information_controller.dart';
import 'package:yummate/screens/features/additional_information/widgets/activity_level_widget.dart';
import 'package:yummate/screens/features/additional_information/widgets/body_metrics_widget.dart';
import 'package:yummate/screens/features/additional_information/widgets/dietary_preferences_widget.dart';
import 'package:yummate/screens/features/additional_information/widgets/favorite_cuisines_widget.dart';
import 'package:yummate/screens/features/additional_information/widgets/health_info_widget.dart';
import 'package:yummate/screens/features/additional_information/widgets/primary_goal_widget.dart';

class AdditionalInformationScreen extends StatelessWidget {
  const AdditionalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdditionalInfoController());

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Additional Information'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Obx(() => LinearProgressIndicator(
              value: (controller.currentPage.value + 1) / 6,
              minHeight: 4,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7CB342)),
            )),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (page) => controller.currentPage.value = page,
                children: const [
                  BodyMetricsWidget(),
                  ActivityLevelWidget(),
                  PrimaryGoalWidget(),
                  DietaryPreferencesWidget(),
                  FavoriteCuisinesWidget(),
                  HealthInfoWidget(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Continue / Complete button
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    final isNext = controller.currentPage.value < 5;
                    return ElevatedButton(
                      onPressed: isNext ? controller.nextPage : controller.saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7CB342),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        isNext ? 'Continue' : 'Complete',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                // Skip button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      if (controller.currentPage.value < 5) {
                        controller.skipToEnd();
                      } else {
                        Get.back();
                      }
                    },
                    child: Text(
                      controller.currentPage.value < 5 ? 'Skip' : 'Close',
                      style: const TextStyle(color: Color(0xFF7CB342)),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
