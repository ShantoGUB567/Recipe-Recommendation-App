// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'dart:convert';
// import 'package:yummate/models/user_profile_model.dart';
// import 'package:yummate/core/widgets/primary_button.dart';

// // GetX Controller for OnboardingProfile
// class OnboardingProfileController extends GetxController {
//   late PageController pageController;
  
//   // Reactive variables
//   final RxInt currentPage = 0.obs;
//   final RxBool isLoading = false.obs;

//   // Form data
//   final TextEditingController ageController = TextEditingController();
//   final TextEditingController heightController = TextEditingController();
//   final TextEditingController weightController = TextEditingController();
//   final TextEditingController allergiesController = TextEditingController();
//   final TextEditingController medicalController = TextEditingController();

//   final Rxn<String> selectedGender = Rxn<String>();
//   final Rxn<String> selectedActivityLevel = Rxn<String>();
//   final Rxn<String> selectedPrimaryGoal = Rxn<String>();
//   final RxList<String> selectedDietaryPreferences = <String>[].obs;
//   final RxList<String> selectedAllergies = <String>[].obs;
//   final RxList<String> selectedMedicalConditions = <String>[].obs;

//   final List<String> genderOptions = ['Male', 'Female', 'Other'];
//   final List<String> activityLevels = [
//     'Sedentary',
//     'Lightly Active',
//     'Moderately Active',
//     'Very Active'
//   ];
//   final List<String> primaryGoals = [
//     'Weight Loss',
//     'Muscle Gain',
//     'Maintenance'
//   ];
//   final List<String> dietaryOptions = ['Vegan', 'Keto', 'Paleo', 'Standard'];
//   final List<String> commonAllergies = [
//     'Peanuts',
//     'Tree Nuts',
//     'Milk',
//     'Eggs',
//     'Fish',
//     'Shellfish',
//     'Soy',
//     'Wheat',
//     'Sesame',
//     'Mustard'
//   ];
//   final List<String> commonMedicalConditions = [
//     'Diabetes',
//     'Hypertension',
//     'Asthma',
//     'Heart Disease',
//     'Thyroid',
//     'Arthritis',
//     'Celiac Disease',
//     'IBS',
//     'GERD',
//     'High Cholesterol'
//   ];

//   @override
//   void onInit() {
//     super.onInit();
//     pageController = PageController();
//   }

//   @override
//   void onClose() {
//     pageController.dispose();
//     ageController.dispose();
//     heightController.dispose();
//     weightController.dispose();
//     allergiesController.dispose();
//     medicalController.dispose();
//     super.onClose();
//   }

//   void nextPage() {
//     if (currentPage.value < 4) {
//       pageController.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void previousPage() {
//     if (currentPage.value > 0) {
//       pageController.previousPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   bool validateCurrentPage() {
//     switch (currentPage.value) {
//       case 0: // Body Metrics
//         return ageController.text.isNotEmpty &&
//             selectedGender.value != null &&
//             heightController.text.isNotEmpty &&
//             weightController.text.isNotEmpty;
//       case 1: // Activity Level
//         return selectedActivityLevel.value != null;
//       case 2: // Primary Goal
//         return selectedPrimaryGoal.value != null;
//       case 3: // Dietary Preferences
//         return selectedDietaryPreferences.isNotEmpty;
//       case 4: // Health Constraints
//         return true; // Optional fields
//       default:
//         return false;
//     }
//   }

//   Future<void> saveProfile() async {
//     if (!validateCurrentPage()) {
//       EasyLoading.showError('Please complete all required fields');
//       return;
//     }

//     isLoading.value = true;
//     EasyLoading.show(status: 'Saving your profile...');

//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         EasyLoading.dismiss();
//         EasyLoading.showError('User not authenticated');
//         isLoading.value = false;
//         return;
//       }

//       final userAllergies = [
//         ...selectedAllergies,
//         ...allergiesController.text
//             .split(',')
//             .map((e) => e.trim())
//             .where((e) => e.isNotEmpty)
//             .toList()
//       ].toSet().toList();
      
//       final userMedicalConditions = [
//         ...selectedMedicalConditions,
//         ...medicalController.text
//             .split(',')
//             .map((e) => e.trim())
//             .where((e) => e.isNotEmpty)
//             .toList()
//       ].toSet().toList();

//       final updatedProfile = UserProfile(
//         uid: user.uid,
//         age: ageController.text,
//         gender: selectedGender.value!,
//         height: heightController.text,
//         weight: weightController.text,
//         activityLevel: selectedActivityLevel.value!,
//         primaryGoal: selectedPrimaryGoal.value!,
//         dietaryPreferences: selectedDietaryPreferences.toList(),
//         allergies: userAllergies,
//         medicalConditions: userMedicalConditions,
//         calorieGoal: null,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );

//       // Save to local storage first
//       final prefs = await SharedPreferences.getInstance();
//       final profileJson = updatedProfile.toJson();
//       // Convert DateTime to ISO strings for JSON serialization
//       profileJson['createdAt'] = updatedProfile.createdAt.toIso8601String();
//       profileJson['updatedAt'] = updatedProfile.updatedAt.toIso8601String();
//       await prefs.setString('user_profile', jsonEncode(profileJson));
//       print('✓ Profile saved locally');

//       // Try to save to Firebase (but don't block if it fails)
//       try {
//         await FirebaseFirestore.instance
//             .collection('user_profiles')
//             .doc(user.uid)
//             .set(updatedProfile.toJson());
//         print('✓ Profile saved to Firebase');
//       } catch (firebaseError) {
//         print('⚠️ Firebase sync failed (profile saved locally): $firebaseError');
//         // Continue anyway - local save was successful
//       }

//       // Show success since local save worked
//       EasyLoading.dismiss();
//       EasyLoading.showSuccess('Profile saved successfully!');

//       // Navigate to home screen
//       Future.delayed(const Duration(milliseconds: 1500), () {
//         isLoading.value = false;
//         Get.offAllNamed('/home');
//       });
//     } on FirebaseAuthException catch (e) {
//       print('✗ Firebase Auth Error: $e');
//       EasyLoading.dismiss();
//       EasyLoading.showError('Authentication error: ${e.message}');
//       isLoading.value = false;
//     } catch (e) {
//       print('✗ Error saving profile: $e');
//       EasyLoading.dismiss();
//       EasyLoading.showError('Failed to save profile: $e');
//       isLoading.value = false;
//     }
//   }
// }

// class OnboardingProfileScreen extends StatelessWidget {
//   const OnboardingProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(OnboardingProfileController());
    
//     return WillPopScope(
//       onWillPop: () async => false, // Prevent back navigation
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: const Text('Complete Your Profile'),
//           centerTitle: true,
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//         ),
//         body: Column(
//           children: [
//             // Progress Indicator
//             Obx(
//               () => LinearProgressIndicator(
//                 value: (controller.currentPage.value + 1) / 5,
//                 minHeight: 4,
//                 backgroundColor: Colors.grey[300],
//                 valueColor: const AlwaysStoppedAnimation<Color>(
//                   Color(0xFF7CB342),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: PageView(
//                 controller: controller.pageController,
//                 physics: const NeverScrollableScrollPhysics(),
//                 onPageChanged: (page) {
//                   controller.currentPage.value = page;
//                 },
//                 children: [
//                   // Page 0: Body Metrics
//                   _buildBodyMetricsPage(context, controller),
//                   // Page 1: Activity Level
//                   _buildActivityLevelPage(context, controller),
//                   // Page 2: Primary Goal
//                   _buildPrimaryGoalPage(context, controller),
//                   // Page 3: Dietary Preferences
//                   _buildDietaryPreferencesPage(context, controller),
//                   // Page 4: Health Constraints
//                   _buildHealthConstraintsPage(context, controller),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         bottomNavigationBar: Container(
//           padding: const EdgeInsets.all(16),
//           child: Obx(
//             () => Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 if (controller.currentPage.value > 0)
//                   ElevatedButton(
//                     onPressed: controller.previousPage,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[400],
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                     ),
//                     child: const Text('Back'),
//                   )
//                 else
//                   const SizedBox(width: 80),
//                 if (controller.currentPage.value < 4)
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 16),
//                       child: SizedBox(
//                         height: 48,
//                         child: PrimaryButton(
//                           text: 'Next',
//                           onPressed: controller.nextPage,
//                           isEnabled: controller.validateCurrentPage(),
//                         ),
//                       ),
//                     ),
//                   )
//                 else
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 16),
//                       child: SizedBox(
//                         height: 48,
//                         child: PrimaryButton(
//                           text: 'Complete Profile',
//                           onPressed: controller.saveProfile,
//                           isLoading: controller.isLoading.value,
//                           isEnabled: !controller.isLoading.value,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBodyMetricsPage(BuildContext context, OnboardingProfileController controller) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 20),
//           Text(
//             'Body Metrics',
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Tell us about your physical characteristics',
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           const SizedBox(height: 32),
//           // Age
//           TextField(
//             controller: controller.ageController,
//             keyboardType: TextInputType.number,
//             onChanged: (_) => controller.validateCurrentPage(),
//             decoration: InputDecoration(
//               labelText: 'Age *',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               prefixIcon: const Icon(Icons.calendar_today),
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Gender
//           Obx(
//             () => DropdownButtonFormField<String>(
//               value: controller.selectedGender.value,
//               items: controller.genderOptions.map((gender) {
//                 return DropdownMenuItem(value: gender, child: Text(gender));
//               }).toList(),
//               onChanged: (value) {
//                 controller.selectedGender.value = value;
//               },
//               decoration: InputDecoration(
//                 labelText: 'Gender *',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 prefixIcon: const Icon(Icons.person),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Height
//           TextField(
//             controller: controller.heightController,
//             keyboardType: TextInputType.number,
//             onChanged: (_) => controller.validateCurrentPage(),
//             decoration: InputDecoration(
//               labelText: 'Height (cm) *',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               prefixIcon: const Icon(Icons.height),
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Weight
//           TextField(
//             controller: controller.weightController,
//             keyboardType: TextInputType.number,
//             onChanged: (_) => controller.validateCurrentPage(),
//             decoration: InputDecoration(
//               labelText: 'Weight (kg) *',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               prefixIcon: const Icon(Icons.scale),
//             ),
//           ),
//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }

//   Widget _buildActivityLevelPage(BuildContext context, OnboardingProfileController controller) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 20),
//           Text(
//             'Activity Level',
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'How active are you in your daily life?',
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           const SizedBox(height: 32),
//           ...controller.activityLevels.map((level) {
//             return Obx(
//               () => Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: RadioListTile<String>(
//                   value: level,
//                   groupValue: controller.selectedActivityLevel.value,
//                   onChanged: (value) {
//                     controller.selectedActivityLevel.value = value;
//                   },
//                   title: Text(level),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }

//   Widget _buildPrimaryGoalPage(BuildContext context, OnboardingProfileController controller) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 20),
//           Text(
//             'Primary Goal',
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'What is your primary fitness goal?',
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           const SizedBox(height: 32),
//           ...controller.primaryGoals.map((goal) {
//             return Obx(
//               () => Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: RadioListTile<String>(
//                   value: goal,
//                   groupValue: controller.selectedPrimaryGoal.value,
//                   onChanged: (value) {
//                     controller.selectedPrimaryGoal.value = value;
//                   },
//                   title: Text(goal),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }

//   Widget _buildDietaryPreferencesPage(BuildContext context, OnboardingProfileController controller) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 20),
//           Text(
//             'Dietary Preferences',
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Select one or more dietary preferences',
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           const SizedBox(height: 32),
//           Obx(
//             () => Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: controller.dietaryOptions.map((diet) {
//                 final isSelected = controller.selectedDietaryPreferences.contains(diet);
//                 return FilterChip(
//                   label: Text(diet),
//                   selected: isSelected,
//                   onSelected: (selected) {
//                     if (selected) {
//                       controller.selectedDietaryPreferences.add(diet);
//                     } else {
//                       controller.selectedDietaryPreferences.remove(diet);
//                     }
//                   },
//                   backgroundColor: Colors.transparent,
//                   selectedColor: const Color(0xFF7CB342).withOpacity(0.2),
//                   side: BorderSide(
//                     color: isSelected
//                         ? const Color(0xFF7CB342)
//                         : Colors.grey[400]!,
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }

//   Widget _buildHealthConstraintsPage(BuildContext context, OnboardingProfileController controller) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 20),
//           Text(
//             'Health Information',
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Add any allergies or medical conditions (optional)',
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           const SizedBox(height: 32),
//           // Allergies Section
//           Text(
//             'Allergies',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: controller.allergiesController,
//                   decoration: InputDecoration(
//                     hintText: 'Add allergy',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Container(
//                 height: 48,
//                 width: 48,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF7CB342),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: () {
//                       if (controller.allergiesController.text.isNotEmpty) {
//                         controller.selectedAllergies.add(controller.allergiesController.text);
//                         controller.allergiesController.clear();
//                       }
//                     },
//                     borderRadius: BorderRadius.circular(8),
//                     child: const Icon(
//                       Icons.add,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           // Selected Allergies
//           Obx(
//             () => controller.selectedAllergies.isNotEmpty
//                 ? Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Selected:',
//                         style: Theme.of(context).textTheme.bodySmall,
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: controller.selectedAllergies.map((allergy) {
//                           return Chip(
//                             label: Text(allergy),
//                             onDeleted: () {
//                               controller.selectedAllergies.remove(allergy);
//                             },
//                             backgroundColor: const Color(0xFF7CB342).withOpacity(0.2),
//                             deleteIcon: const Icon(Icons.close, size: 18),
//                           );
//                         }).toList(),
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                   )
//                 : const SizedBox.shrink(),
//           ),
//           // Common Allergies
//           Text(
//             'Common allergies:',
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Obx(
//             () => Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: controller.commonAllergies.map((allergy) {
//                 final isSelected = controller.selectedAllergies.contains(allergy);
//                 return FilterChip(
//                   label: Text(allergy),
//                   selected: isSelected,
//                   onSelected: (selected) {
//                     if (selected) {
//                       controller.selectedAllergies.add(allergy);
//                     } else {
//                       controller.selectedAllergies.remove(allergy);
//                     }
//                   },
//                   backgroundColor: Colors.transparent,
//                   selectedColor: const Color(0xFF7CB342).withOpacity(0.2),
//                   side: BorderSide(
//                     color: isSelected
//                         ? const Color(0xFF7CB342)
//                         : Colors.grey[400]!,
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//           const SizedBox(height: 32),
//           // Medical Conditions Section
//           Text(
//             'Medical Conditions',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: controller.medicalController,
//                   decoration: InputDecoration(
//                     hintText: 'Add condition',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Container(
//                 height: 48,
//                 width: 48,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF7CB342),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: () {
//                       if (controller.medicalController.text.isNotEmpty) {
//                         controller.selectedMedicalConditions
//                             .add(controller.medicalController.text);
//                         controller.medicalController.clear();
//                       }
//                     },
//                     borderRadius: BorderRadius.circular(8),
//                     child: const Icon(
//                       Icons.add,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           // Selected Medical Conditions
//           Obx(
//             () => controller.selectedMedicalConditions.isNotEmpty
//                 ? Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Selected:',
//                         style: Theme.of(context).textTheme.bodySmall,
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: controller.selectedMedicalConditions.map((condition) {
//                           return Chip(
//                             label: Text(condition),
//                             onDeleted: () {
//                               controller.selectedMedicalConditions.remove(condition);
//                             },
//                             backgroundColor: const Color(0xFF7CB342).withOpacity(0.2),
//                             deleteIcon: const Icon(Icons.close, size: 18),
//                           );
//                         }).toList(),
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                   )
//                 : const SizedBox.shrink(),
//           ),
//           // Common Medical Conditions
//           Text(
//             'Common conditions:',
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Obx(
//             () => Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: controller.commonMedicalConditions.map((condition) {
//                 final isSelected =
//                     controller.selectedMedicalConditions.contains(condition);
//                 return FilterChip(
//                   label: Text(condition),
//                   selected: isSelected,
//                   onSelected: (selected) {
//                     if (selected) {
//                       controller.selectedMedicalConditions.add(condition);
//                     } else {
//                       controller.selectedMedicalConditions.remove(condition);
//                     }
//                   },
//                   backgroundColor: Colors.transparent,
//                   selectedColor: const Color(0xFF7CB342).withOpacity(0.2),
//                   side: BorderSide(
//                     color: isSelected
//                         ? const Color(0xFF7CB342)
//                         : Colors.grey[400]!,
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }
// }
