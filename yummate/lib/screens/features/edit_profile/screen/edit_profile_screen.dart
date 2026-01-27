import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:convert';
import 'package:yummate/screens/features/edit_profile/widgets/edit_profile_image_picker.dart';
import 'package:yummate/screens/features/edit_profile/widgets/edit_profile_basic_info_section.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../widgets_new/health_metrics_section.dart';
import '../widgets_new/gender_section.dart';
import '../widgets_new/activity_level_section.dart';
import '../widgets_new/primary_goal_section.dart';
import '../widgets_new/dietary_preferences_section.dart';
import '../widgets_new/spicy_level_section.dart';
import '../widgets_new/cuisines_section.dart';
import '../widgets_new/allergies_section.dart';
import '../widgets_new/medical_conditions_section.dart';
import '../widgets_new/save_profile_button.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final String? uid;

  const EditProfileScreen({super.key, this.userData, this.uid});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Basic Info
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController usernameController;
  late TextEditingController bioController;
  late TextEditingController locationController;
  late TextEditingController specialtyDishesController;
  late TextEditingController foodPhilosophyController;

  // Health & Preferences
  late TextEditingController ageController;
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController allergiesController;
  late TextEditingController medicalController;
  late TextEditingController cuisinesController;

  String? selectedGender;
  String? selectedActivityLevel;
  String? selectedPrimaryGoal;
  String? selectedCookingLevel;
  List<String> selectedDietaryPreferences = [];
  List<String> selectedCuisines = [];
  List<String> selectedAllergies = [];
  List<String> selectedMedicalConditions = [];
  int spicyLevel = 2;
  File? profileImage;

  // Store original data for comparison
  Map<String, dynamic> originalData = {};

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
  ];
  final List<String> primaryGoals = [
    'Weight Loss',
    'Muscle Gain',
    'Maintenance',
  ];
  final List<String> dietaryOptions = ['Vegan', 'Keto', 'Paleo', 'Standard'];
  final List<String> commonCuisines = [
    'Bangladeshi',
    'Indian',
    'Chinese',
    'Italian',
    'Thai',
    'Mexican',
    'American',
    'Japanese',
    'Korean',
    'Mediterranean',
  ];
  final List<String> commonAllergies = [
    'Peanuts',
    'Tree Nuts',
    'Milk',
    'Eggs',
    'Fish',
    'Shellfish',
    'Soy',
    'Wheat',
    'Sesame',
    'Mustard',
  ];
  final List<String> commonMedicalConditions = [
    'Diabetes',
    'Hypertension',
    'Asthma',
    'Heart Disease',
    'Thyroid',
    'Arthritis',
    'Celiac Disease',
    'IBS',
    'GERD',
    'High Cholesterol',
  ];

  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadDataFromFirebase();
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    usernameController = TextEditingController();
    bioController = TextEditingController();
    locationController = TextEditingController();
    specialtyDishesController = TextEditingController();
    foodPhilosophyController = TextEditingController();
    ageController = TextEditingController();
    heightController = TextEditingController();
    weightController = TextEditingController();
    allergiesController = TextEditingController();
    medicalController = TextEditingController();
    cuisinesController = TextEditingController();
  }

  Future<void> _loadDataFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      // Fetch from users table first (has basic info)
      final userSnapshot = await _db.child('users/${user.uid}').get();
      final userProfileSnapshot = await _db
          .child('user_profiles/${user.uid}')
          .get();

      final data = <String, dynamic>{};

      // Merge data from both tables
      if (userSnapshot.exists) {
        data.addAll(Map<String, dynamic>.from(userSnapshot.value as Map));
      }
      if (userProfileSnapshot.exists) {
        data.addAll(
          Map<String, dynamic>.from(userProfileSnapshot.value as Map),
        );
      }

      if (data.isNotEmpty) {
        originalData = data;

        setState(() {
          nameController.text = data['name'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phone'] ?? '';
          usernameController.text = data['username'] ?? '';
          bioController.text = data['bio'] ?? '';
          locationController.text = data['location'] ?? '';
          specialtyDishesController.text = data['specialtyDishes'] ?? '';
          foodPhilosophyController.text = data['foodPhilosophy'] ?? '';
          ageController.text = data['age'] ?? '';
          heightController.text = data['height'] ?? '';
          weightController.text = data['weight'] ?? '';
          selectedGender = data['gender'];
          selectedActivityLevel = data['activityLevel'];
          selectedPrimaryGoal = data['primaryGoal'];
          selectedCookingLevel = data['cookingLevel'];
          selectedDietaryPreferences = List<String>.from(
            data['dietaryPreferences'] ?? [],
          );
          selectedCuisines = List<String>.from(data['favorite_cuisines'] ?? []);
          selectedAllergies = List<String>.from(data['allergies'] ?? []);
          selectedMedicalConditions = List<String>.from(
            data['medicalConditions'] ?? [],
          );
          spicyLevel = data['calorieGoal'] ?? 2;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      EasyLoading.showError('Failed to load profile data');
      setState(() => isLoading = false);
    }
  }

  Future<void> saveProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        EasyLoading.showError('User not authenticated');
        return;
      }

      EasyLoading.show(status: 'Saving changes...');

      // Build update map with only changed fields
      final Map<String, dynamic> updateData = {};

      // Handle profile image as base64 if selected
      if (profileImage != null) {
        final bytes = await profileImage!.readAsBytes();
        final base64Image = base64Encode(bytes);
        updateData['profileImageUrl'] = 'data:image/jpeg;base64,$base64Image';
      }

      if (nameController.text != (originalData['name'] ?? '')) {
        updateData['name'] = nameController.text;
      }
      if (emailController.text != (originalData['email'] ?? '')) {
        updateData['email'] = emailController.text;
      }
      if (phoneController.text != (originalData['phone'] ?? '')) {
        updateData['phone'] = phoneController.text;
      }
      if (usernameController.text != (originalData['username'] ?? '')) {
        updateData['username'] = usernameController.text;
      }
      if (bioController.text != (originalData['bio'] ?? '')) {
        updateData['bio'] = bioController.text;
      }
      if (locationController.text != (originalData['location'] ?? '')) {
        updateData['location'] = locationController.text;
      }
      if (selectedCookingLevel != originalData['cookingLevel']) {
        updateData['cookingLevel'] = selectedCookingLevel;
      }
      if (specialtyDishesController.text !=
          (originalData['specialtyDishes'] ?? '')) {
        updateData['specialtyDishes'] = specialtyDishesController.text;
      }
      if (foodPhilosophyController.text !=
          (originalData['foodPhilosophy'] ?? '')) {
        updateData['foodPhilosophy'] = foodPhilosophyController.text;
      }
      if (ageController.text != (originalData['age'] ?? '')) {
        updateData['age'] = ageController.text;
      }
      if (heightController.text != (originalData['height'] ?? '')) {
        updateData['height'] = heightController.text;
      }
      if (weightController.text != (originalData['weight'] ?? '')) {
        updateData['weight'] = weightController.text;
      }
      if (selectedGender != originalData['gender']) {
        updateData['gender'] = selectedGender;
      }
      if (selectedActivityLevel != originalData['activityLevel']) {
        updateData['activityLevel'] = selectedActivityLevel;
      }
      if (selectedPrimaryGoal != originalData['primaryGoal']) {
        updateData['primaryGoal'] = selectedPrimaryGoal;
      }
      if (selectedDietaryPreferences !=
          (originalData['dietaryPreferences'] ?? [])) {
        updateData['dietaryPreferences'] = selectedDietaryPreferences;
      }
      if (selectedCuisines != (originalData['favorite_cuisines'] ?? [])) {
        updateData['favorite_cuisines'] = selectedCuisines;
      }
      if (selectedAllergies != (originalData['allergies'] ?? [])) {
        updateData['allergies'] = selectedAllergies;
      }
      if (selectedMedicalConditions !=
          (originalData['medicalConditions'] ?? [])) {
        updateData['medicalConditions'] = selectedMedicalConditions;
      }
      if (spicyLevel != (originalData['calorieGoal'] ?? 2)) {
        updateData['calorieGoal'] = spicyLevel;
      }

      // Only update if there are changes
      if (updateData.isNotEmpty) {
        await _db.child('users/${user.uid}').update(updateData);
        await _db.child('user_profiles/${user.uid}').update(updateData);
      }

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Profile updated successfully!');

      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.back();
      });
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to save profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Profile Image Picker
            EditProfileImagePicker(
              onImagePicked: (image) => setState(() => profileImage = image),
              currentImageUrl: originalData['profileImageUrl'],
              displayName: nameController.text,
            ),
            const SizedBox(height: 24),

            // Basic Info Section
            EditProfileBasicInfoSection(
              nameController: nameController,
              emailController: emailController,
              phoneController: phoneController,
              usernameController: usernameController,
              bioController: bioController,
              locationController: locationController,
              specialtyDishesController: specialtyDishesController,
              foodPhilosophyController: foodPhilosophyController,
              cookingLevel: selectedCookingLevel,
              onCookingLevelChanged: (value) {
                setState(() => selectedCookingLevel = value);
              },
            ),
            const SizedBox(height: 32),

            // Health Metrics Section
            HealthMetricsSection(
              ageController: ageController,
              heightController: heightController,
              weightController: weightController,
            ),
            const SizedBox(height: 16),

            // Gender Section
            GenderSection(
              selectedGender: selectedGender,
              genderOptions: genderOptions,
              onChanged: (value) => setState(() => selectedGender = value),
            ),
            const SizedBox(height: 16),

            // Activity Level Section
            ActivityLevelSection(
              selectedActivityLevel: selectedActivityLevel,
              activityLevels: activityLevels,
              onChanged: (value) =>
                  setState(() => selectedActivityLevel = value),
            ),
            const SizedBox(height: 16),

            // Primary Goal Section
            PrimaryGoalSection(
              selectedPrimaryGoal: selectedPrimaryGoal,
              primaryGoals: primaryGoals,
              onChanged: (value) =>
                  setState(() => selectedPrimaryGoal = value),
            ),
            const SizedBox(height: 16),

            // Dietary Preferences Section
            DietaryPreferencesSection(
              selectedDietaryPreferences: selectedDietaryPreferences,
              dietaryOptions: dietaryOptions,
              onChanged: (value) =>
                  setState(() => selectedDietaryPreferences = value),
            ),
            const SizedBox(height: 16),

            // Spicy Level Section
            SpicyLevelSection(
              spicyLevel: spicyLevel,
              onChanged: (value) => setState(() => spicyLevel = value),
            ),
            const SizedBox(height: 16),

            // Cuisines Section
            CuisinesSection(
              selectedCuisines: selectedCuisines,
              commonCuisines: commonCuisines,
              cuisinesController: cuisinesController,
              onAddCuisine: () {
                if (cuisinesController.text.isNotEmpty) {
                  setState(() {
                    selectedCuisines.add(cuisinesController.text);
                  });
                  cuisinesController.clear();
                }
              },
              onChanged: (value) =>
                  setState(() => selectedCuisines = value),
            ),
            const SizedBox(height: 16),

            // Allergies Section
            AllergiesSection(
              selectedAllergies: selectedAllergies,
              commonAllergies: commonAllergies,
              allergiesController: allergiesController,
              onAddAllergy: () {
                if (allergiesController.text.isNotEmpty) {
                  setState(() {
                    selectedAllergies.add(allergiesController.text);
                  });
                  allergiesController.clear();
                }
              },
              onChanged: (value) =>
                  setState(() => selectedAllergies = value),
            ),
            const SizedBox(height: 16),

            // Medical Conditions Section
            MedicalConditionsSection(
              selectedMedicalConditions: selectedMedicalConditions,
              commonMedicalConditions: commonMedicalConditions,
              medicalController: medicalController,
              onAddCondition: () {
                if (medicalController.text.isNotEmpty) {
                  setState(() {
                    selectedMedicalConditions.add(medicalController.text);
                  });
                  medicalController.clear();
                }
              },
              onChanged: (value) =>
                  setState(() => selectedMedicalConditions = value),
            ),
            const SizedBox(height: 32),

            // Save Button
            SaveProfileButton(
              onPressed: saveProfile,
              isLoading: false,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
