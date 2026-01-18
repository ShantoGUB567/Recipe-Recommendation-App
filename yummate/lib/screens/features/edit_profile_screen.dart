import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yummate/models/user_profile_model.dart';
import 'package:yummate/core/widgets/primary_button.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String uid;
  final UserProfile? userProfile;

  const EditProfileScreen({
    super.key,
    required this.userData,
    required this.uid,
    this.userProfile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Old profile fields
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController usernameController;

  // New profile fields
  late TextEditingController ageController;
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController allergiesController;
  late TextEditingController medicalController;

  int spicyLevel = 2;
  String? selectedGender;
  String? selectedActivityLevel;
  String? selectedPrimaryGoal;
  List<String> selectedCuisines = [];
  List<String> selectedAllergies = [];
  List<String> selectedDietaryPreferences = [];
  File? profileImage;
  bool _isSaving = false;

  final List<String> cuisineOptions = [
    'Bangladeshi',
    'Indian',
    'Chinese',
    'Italian',
    'Thai',
    'Mexican',
    'American',
  ];
  final List<String> allergyOptions = [
    'Peanuts',
    'Dairy',
    'Gluten',
    'Shellfish',
    'Eggs',
    'Tree Nuts',
  ];
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

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Old profile fields
    nameController = TextEditingController(text: widget.userData['name'] ?? '');
    emailController = TextEditingController(
      text: widget.userData['email'] ?? '',
    );
    phoneController = TextEditingController(
      text: widget.userData['phone'] ?? '',
    );
    usernameController = TextEditingController(
      text: widget.userData['username'] ?? '',
    );

    // New profile fields
    if (widget.userProfile != null) {
      ageController = TextEditingController(text: widget.userProfile!.age);
      heightController = TextEditingController(text: widget.userProfile!.height);
      weightController = TextEditingController(text: widget.userProfile!.weight);
      allergiesController = TextEditingController(
        text: widget.userProfile!.allergies.join(', '),
      );
      medicalController = TextEditingController(
        text: widget.userProfile!.medicalConditions.join(', '),
      );
      selectedGender = widget.userProfile!.gender;
      selectedActivityLevel = widget.userProfile!.activityLevel;
      selectedPrimaryGoal = widget.userProfile!.primaryGoal;
      selectedDietaryPreferences = widget.userProfile!.dietaryPreferences;
    } else {
      ageController = TextEditingController();
      heightController = TextEditingController();
      weightController = TextEditingController();
      allergiesController = TextEditingController();
      medicalController = TextEditingController();
    }

    spicyLevel = widget.userData['spicy_level'] ?? 2;
    selectedCuisines = List<String>.from(
      widget.userData['favorite_cuisines'] ?? [],
    );
    selectedAllergies = List<String>.from(widget.userData['allergies'] ?? []);
  }

  Future<void> pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => profileImage = File(image.path));
    }
  }

  Future<void> _saveUserProfile() async {
    if (!_validateProfileFields()) {
      Get.snackbar('Error', 'Please fill all required fields',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final allergies =
          allergiesController.text.split(',').map((e) => e.trim()).toList();
      final medicalConditions =
          medicalController.text.split(',').map((e) => e.trim()).toList();

      final userProfile = UserProfile(
        uid: user.uid,
        age: ageController.text,
        gender: selectedGender!,
        height: heightController.text,
        weight: weightController.text,
        activityLevel: selectedActivityLevel!,
        primaryGoal: selectedPrimaryGoal!,
        dietaryPreferences: selectedDietaryPreferences,
        allergies: allergies.where((e) => e.isNotEmpty).toList(),
        medicalConditions: medicalConditions.where((e) => e.isNotEmpty).toList(),
        createdAt: widget.userProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(user.uid)
          .update(userProfile.toJson());

      Get.snackbar('Success', 'Profile updated successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);

      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  bool _validateProfileFields() {
    return ageController.text.isNotEmpty &&
        selectedGender != null &&
        heightController.text.isNotEmpty &&
        weightController.text.isNotEmpty &&
        selectedActivityLevel != null &&
        selectedPrimaryGoal != null &&
        selectedDietaryPreferences.isNotEmpty;
  }

  Future<void> saveOldProfile() async {
    try {
      await _db.child('users/${widget.uid}').update({
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'username': usernameController.text,
        'spicy_level': spicyLevel,
        'favorite_cuisines': selectedCuisines,
        'allergies': selectedAllergies,
      });
      Get.snackbar(
        'Success',
        'Profile updated',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show new profile edit form if UserProfile exists
    if (widget.userProfile != null) {
      return _buildNewProfileEditForm();
    }

    // Otherwise show old profile edit form
    return _buildOldProfileEditForm();
  }

  Widget _buildNewProfileEditForm() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Body Metrics
            _buildSectionTitle('Body Metrics'),
            const SizedBox(height: 12),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedGender,
              items: genderOptions.map((g) {
                return DropdownMenuItem(value: g, child: Text(g));
              }).toList(),
              onChanged: (value) => setState(() => selectedGender = value),
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
            // Activity Level
            _buildSectionTitle('Activity Level'),
            const SizedBox(height: 12),
            ...activityLevels.map((level) {
              return RadioListTile<String>(
                value: level,
                groupValue: selectedActivityLevel,
                onChanged: (value) =>
                    setState(() => selectedActivityLevel = value),
                title: Text(level),
              );
            }).toList(),
            const SizedBox(height: 24),
            // Primary Goal
            _buildSectionTitle('Primary Goal'),
            const SizedBox(height: 12),
            ...primaryGoals.map((goal) {
              return RadioListTile<String>(
                value: goal,
                groupValue: selectedPrimaryGoal,
                onChanged: (value) => setState(() => selectedPrimaryGoal = value),
                title: Text(goal),
              );
            }).toList(),
            const SizedBox(height: 24),
            // Dietary Preferences
            _buildSectionTitle('Dietary Preferences'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dietaryOptions.map((diet) {
                final isSelected = selectedDietaryPreferences.contains(diet);
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
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Health Constraints
            _buildSectionTitle('Health Information'),
            const SizedBox(height: 12),
            TextField(
              controller: allergiesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Allergies (comma separated)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: medicalController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Medical Conditions (comma separated)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 32),
            // Save Button
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Update Profile',
                onPressed: _saveUserProfile,
                isEnabled: !_isSaving,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOldProfileEditForm() {
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
            // Profile photo
            Center(
              child: GestureDetector(
                onTap: pickProfileImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.shade100,
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  child: profileImage != null
                      ? ClipOval(
                          child: Image.file(profileImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.orange,
                              size: 32,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Change Photo',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Name
            Text('Name', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Enter name',
              ),
            ),
            const SizedBox(height: 16),
            // Username
            Text(
              'Username',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Enter username',
              ),
            ),
            const SizedBox(height: 16),
            // Email
            Text('Email', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 16),
            // Phone
            Text('Phone', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Enter phone number',
              ),
            ),
            const SizedBox(height: 24),
            // Spicy Level
            Text(
              'Spicy Level',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🌶️ Mild'),
                      Text(
                        '$spicyLevel',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('🌶️🌶️🌶️ Very Hot'),
                    ],
                  ),
                  const SizedBox(height: 8),
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
            const SizedBox(height: 24),
            // Favorite Cuisines
            Text(
              'Favorite Cuisines',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cuisineOptions.map((cuisine) {
                final isSelected = selectedCuisines.contains(cuisine);
                return FilterChip(
                  label: Text(cuisine),
                  selected: isSelected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        selectedCuisines.add(cuisine);
                      } else {
                        selectedCuisines.remove(cuisine);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Allergies
            Text(
              'Allergies',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allergyOptions.map((allergy) {
                final isSelected = selectedAllergies.contains(allergy);
                return FilterChip(
                  label: Text(allergy),
                  selected: isSelected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        selectedAllergies.add(allergy);
                      } else {
                        selectedAllergies.remove(allergy);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saveOldProfile,
                icon: const Icon(Icons.check),
                label: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
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
    super.dispose();
  }
}
