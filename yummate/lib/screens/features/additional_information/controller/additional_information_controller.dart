import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';
import 'package:yummate/models/user_profile_model.dart';

class AdditionalInfoController extends GetxController {
  late PageController pageController;

  // Reactive variables
  final RxInt currentPage = 0.obs;
  final RxBool isLoading = false.obs;

  // Form data
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController medicalController = TextEditingController();
  final TextEditingController cuisinesController = TextEditingController();

  final Rxn<String> selectedGender = Rxn<String>();
  final Rxn<String> selectedActivityLevel = Rxn<String>();
  final Rxn<String> selectedPrimaryGoal = Rxn<String>();
  final RxList<String> selectedDietaryPreferences = <String>[].obs;
  final RxList<String> selectedCuisines = <String>[].obs;
  final RxList<String> selectedAllergies = <String>[].obs;
  final RxList<String> selectedMedicalConditions = <String>[].obs;

  final RxInt spicyLevel = 1.obs;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active'
  ];
  final List<String> primaryGoals = [
    'Weight Loss',
    'Muscle Gain',
    'Maintenance'
  ];
  final List<String> dietaryOptions = ['Vegan', 'Keto', 'Paleo', 'Standard'];
  final List<String> commonCuisines = [
    'Bangladeshi', 'Indian', 'Chinese', 'Italian', 'Thai', 'Mexican', 'American', 'Japanese', 'Korean', 'Mediterranean'
  ];
  final List<String> commonAllergies = [
    'Peanuts','Tree Nuts','Milk','Eggs','Fish','Shellfish','Soy','Wheat','Sesame','Mustard'
  ];
  final List<String> commonMedicalConditions = [
    'Diabetes','Hypertension','Asthma','Heart Disease','Thyroid','Arthritis','Celiac Disease','IBS','GERD','High Cholesterol'
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    pageController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    allergiesController.dispose();
    medicalController.dispose();
    cuisinesController.dispose();
    super.onClose();
  }

  void nextPage() {
    if (currentPage.value < 5) {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void skipToEnd() {
    pageController.jumpToPage(5);
  }

  Future<void> saveProfile() async {

    isLoading.value = true;
    EasyLoading.show(status: 'Saving your profile...');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        EasyLoading.dismiss();
        EasyLoading.showError('User not authenticated');
        isLoading.value = false;
        return;
      }

      final userAllergies = [
        ...selectedAllergies,
        ...allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty)
      ].toSet().toList();

      final userMedicalConditions = [
        ...selectedMedicalConditions,
        ...medicalController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty)
      ].toSet().toList();

      final userCuisines = [
        ...selectedCuisines,
        ...cuisinesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty)
      ].toSet().toList();

      final updatedProfile = UserProfile(
        uid: user.uid,
        age: ageController.text,
        gender: selectedGender.value ?? '',
        height: heightController.text,
        weight: weightController.text,
        activityLevel: selectedActivityLevel.value ?? '',
        primaryGoal: selectedPrimaryGoal.value ?? '',
        dietaryPreferences: selectedDietaryPreferences.toList(),
        allergies: userAllergies,
        medicalConditions: userMedicalConditions,
        calorieGoal: spicyLevel.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Prepare Firebase data without DateTime objects, empty strings as null
      final Map<String, dynamic> firebaseData = {
        'uid': user.uid,
        'age': ageController.text.isEmpty ? null : ageController.text,
        'gender': selectedGender.value == null ? null : selectedGender.value,
        'height': heightController.text.isEmpty ? null : heightController.text,
        'weight': weightController.text.isEmpty ? null : weightController.text,
        'activityLevel': selectedActivityLevel.value == null ? null : selectedActivityLevel.value,
        'primaryGoal': selectedPrimaryGoal.value == null ? null : selectedPrimaryGoal.value,
        'dietaryPreferences': selectedDietaryPreferences.isEmpty ? null : selectedDietaryPreferences,
        'favorite_cuisines': userCuisines.isEmpty ? null : userCuisines,
        'allergies': userAllergies.isEmpty ? null : userAllergies,
        'medicalConditions': userMedicalConditions.isEmpty ? null : userMedicalConditions,
        'calorieGoal': spicyLevel.value,
      };

      // Save locally
      final prefs = await SharedPreferences.getInstance();
      final profileJson = updatedProfile.toJson();
      profileJson['createdAt'] = updatedProfile.createdAt.toIso8601String();
      profileJson['updatedAt'] = updatedProfile.updatedAt.toIso8601String();
      await prefs.setString('user_profile', jsonEncode(profileJson));

      // Save to Firebase Realtime Database
      final dbRef = FirebaseDatabase.instance.ref('user_profiles/${user.uid}');
      await dbRef.set(firebaseData);

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Profile saved successfully!');
      Future.delayed(const Duration(milliseconds: 1500), () {
        isLoading.value = false;
        Get.offAllNamed('/home');
      });
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to save profile: $e');
      isLoading.value = false;
    }
  }
}
