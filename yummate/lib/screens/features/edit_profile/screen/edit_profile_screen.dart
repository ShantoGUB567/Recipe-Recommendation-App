import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:yummate/screens/features/edit_profile/widgets/edit_profile_image_picker.dart';
import 'package:yummate/screens/features/edit_profile/widgets/edit_profile_basic_info_section.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final String? uid;

  const EditProfileScreen({
    super.key,
    this.userData,
    this.uid,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Basic Info
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController usernameController;

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
    'Very Active'
  ];
  final List<String> primaryGoals = [
    'Weight Loss',
    'Muscle Gain',
    'Maintenance'
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
    'Mediterranean'
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
    'Mustard'
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
    'High Cholesterol'
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
      final user_profileSnapshot = await _db.child('user_profiles/${user.uid}').get();
      
      final data = <String, dynamic>{};
      
      // Merge data from both tables
      if (userSnapshot.exists) {
        data.addAll(Map<String, dynamic>.from(userSnapshot.value as Map));
      }
      if (user_profileSnapshot.exists) {
        data.addAll(Map<String, dynamic>.from(user_profileSnapshot.value as Map));
      }
      
      if (data.isNotEmpty) {
        originalData = data;
        
        setState(() {
          nameController.text = data['name'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phone'] ?? '';
          usernameController.text = data['username'] ?? '';
          ageController.text = data['age'] ?? '';
          heightController.text = data['height'] ?? '';
          weightController.text = data['weight'] ?? '';
          selectedGender = data['gender'];
          selectedActivityLevel = data['activityLevel'];
          selectedPrimaryGoal = data['primaryGoal'];
          selectedDietaryPreferences = List<String>.from(data['dietaryPreferences'] ?? []);
          selectedCuisines = List<String>.from(data['favorite_cuisines'] ?? []);
          selectedAllergies = List<String>.from(data['allergies'] ?? []);
          selectedMedicalConditions = List<String>.from(data['medicalConditions'] ?? []);
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
      if (selectedDietaryPreferences != (originalData['dietaryPreferences'] ?? [])) {
        updateData['dietaryPreferences'] = selectedDietaryPreferences;
      }
      if (selectedCuisines != (originalData['favorite_cuisines'] ?? [])) {
        updateData['favorite_cuisines'] = selectedCuisines;
      }
      if (selectedAllergies != (originalData['allergies'] ?? [])) {
        updateData['allergies'] = selectedAllergies;
      }
      if (selectedMedicalConditions != (originalData['medicalConditions'] ?? [])) {
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
          title: const Text('Edit Profile'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Picker
            EditProfileImagePicker(
              onImagePicked: (image) => setState(() => profileImage = image),
            ),
            const SizedBox(height: 24),

            // Basic Info Section
            EditProfileBasicInfoSection(
              nameController: nameController,
              emailController: emailController,
              phoneController: phoneController,
              usernameController: usernameController,
            ),
            const SizedBox(height: 32),

            // Health & Preferences Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Age, Height & Weight',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Height (cm)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gender
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gender',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      items: genderOptions
                          .map((gender) =>
                              DropdownMenuItem(value: gender, child: Text(gender)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedGender = value),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Activity Level
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Activity Level',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: activityLevels.map((level) {
                        final isSelected = selectedActivityLevel == level;
                        return FilterChip(
                          label: Text(level),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() =>
                                selectedActivityLevel = selected ? level : null);
                          },
                          selectedColor:
                              const Color(0xFF7CB342).withOpacity(0.2),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Primary Goal
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Primary Goal',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: primaryGoals.map((goal) {
                        final isSelected = selectedPrimaryGoal == goal;
                        return FilterChip(
                          label: Text(goal),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(
                                () => selectedPrimaryGoal = selected ? goal : null);
                          },
                          selectedColor:
                              const Color(0xFF7CB342).withOpacity(0.2),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dietary Preferences
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dietary Preferences',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: dietaryOptions.map((diet) {
                        final isSelected =
                            selectedDietaryPreferences.contains(diet);
                        return FilterChip(
                          label: Text(diet),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedDietaryPreferences.add(diet);
                              } else {
                                selectedDietaryPreferences.remove(diet);
                              }
                            });
                          },
                          selectedColor:
                              const Color(0xFF7CB342).withOpacity(0.2),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Spicy Level
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Spicy Level',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🌶️ Mild'),
                        Text('$spicyLevel',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const Text('🌶️🌶️🌶️ Very Hot'),
                      ],
                    ),
                    Slider(
                      value: spicyLevel.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (value) =>
                          setState(() => spicyLevel = value.toInt()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Favorite Cuisines
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Favorite Cuisines',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 6,
                      children: commonCuisines.map((cuisine) {
                        final isSelected = selectedCuisines.contains(cuisine);
                        return FilterChip(
                          label: Text(cuisine),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedCuisines.add(cuisine);
                              } else {
                                selectedCuisines.remove(cuisine);
                              }
                            });
                          },
                          backgroundColor: Colors.transparent,
                          selectedColor:
                              const Color(0xFF7CB342).withOpacity(0.2),
                          side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF7CB342)
                                  : Colors.grey[400]!),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cuisinesController,
                            decoration: InputDecoration(
                              hintText: 'Add custom cuisine',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                              color: const Color(0xFF7CB342),
                              borderRadius: BorderRadius.circular(8)),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (cuisinesController.text.isNotEmpty) {
                                  setState(() {
                                    selectedCuisines
                                        .add(cuisinesController.text);
                                  });
                                  cuisinesController.clear();
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: const Icon(Icons.add,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (selectedCuisines.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: selectedCuisines.map((cuisine) {
                              return Chip(
                                label: Text(cuisine),
                                onDeleted: () {
                                  setState(() =>
                                      selectedCuisines.remove(cuisine));
                                },
                                backgroundColor:
                                    const Color(0xFF7CB342).withOpacity(0.2),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Allergies
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Allergies',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 6,
                      children: commonAllergies.map((allergy) {
                        final isSelected = selectedAllergies.contains(allergy);
                        return FilterChip(
                          label: Text(allergy),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedAllergies.add(allergy);
                              } else {
                                selectedAllergies.remove(allergy);
                              }
                            });
                          },
                          backgroundColor: Colors.transparent,
                          selectedColor: Colors.red.shade100,
                          side: BorderSide(
                              color: isSelected
                                  ? Colors.red.shade300
                                  : Colors.grey[400]!),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: allergiesController,
                            decoration: InputDecoration(
                              hintText: 'Add custom allergy',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                              color: const Color(0xFF7CB342),
                              borderRadius: BorderRadius.circular(8)),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (allergiesController.text.isNotEmpty) {
                                  setState(() {
                                    selectedAllergies
                                        .add(allergiesController.text);
                                  });
                                  allergiesController.clear();
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: const Icon(Icons.add,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (selectedAllergies.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: selectedAllergies.map((allergy) {
                              return Chip(
                                label: Text(allergy),
                                onDeleted: () {
                                  setState(() =>
                                      selectedAllergies.remove(allergy));
                                },
                                backgroundColor: Colors.red.shade100,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Medical Conditions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Medical Conditions',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 6,
                      children: commonMedicalConditions.map((condition) {
                        final isSelected =
                            selectedMedicalConditions.contains(condition);
                        return FilterChip(
                          label: Text(condition),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedMedicalConditions.add(condition);
                              } else {
                                selectedMedicalConditions.remove(condition);
                              }
                            });
                          },
                          backgroundColor: Colors.transparent,
                          selectedColor: Colors.amber.shade100,
                          side: BorderSide(
                              color: isSelected
                                  ? Colors.amber.shade400
                                  : Colors.grey[400]!),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: medicalController,
                            decoration: InputDecoration(
                              hintText: 'Add custom condition',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                              color: const Color(0xFF7CB342),
                              borderRadius: BorderRadius.circular(8)),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (medicalController.text.isNotEmpty) {
                                  setState(() {
                                    selectedMedicalConditions
                                        .add(medicalController.text);
                                  });
                                  medicalController.clear();
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: const Icon(Icons.add,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (selectedMedicalConditions.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children:
                                selectedMedicalConditions.map((condition) {
                              return Chip(
                                label: Text(condition),
                                onDeleted: () {
                                  setState(() =>
                                      selectedMedicalConditions
                                          .remove(condition));
                                },
                                backgroundColor: Colors.amber.shade100,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saveProfile,
                icon: const Icon(Icons.check),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7CB342),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    allergiesController.dispose();
    medicalController.dispose();
    cuisinesController.dispose();
    super.dispose();
  }
}
