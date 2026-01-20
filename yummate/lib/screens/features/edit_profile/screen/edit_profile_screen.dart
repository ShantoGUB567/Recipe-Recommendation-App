import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:yummate/screens/features/edit_profile/widgets/edit_profile_image_picker.dart';
import 'package:yummate/screens/features/edit_profile/widgets/edit_profile_basic_info_section.dart';
import 'package:yummate/screens/features/edit_profile/widgets/edit_profile_spicy_level_section.dart';
import 'package:yummate/screens/features/edit_profile/widgets/edit_profile_cuisines_section.dart';
import 'package:yummate/screens/features/edit_profile/widgets/edit_profile_allergies_section.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String uid;

  const EditProfileScreen({
    super.key,
    required this.userData,
    required this.uid,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController usernameController;

  int spicyLevel = 2;
  List<String> selectedCuisines = [];
  List<String> selectedAllergies = [];
  File? profileImage;

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

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
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
    spicyLevel = widget.userData['spicy_level'] ?? 2;
    selectedCuisines = List<String>.from(
      widget.userData['favorite_cuisines'] ?? [],
    );
    selectedAllergies = List<String>.from(widget.userData['allergies'] ?? []);
  }

  Future<void> saveProfile() async {
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
      Get.back();
      Get.snackbar(
        'Success',
        'Profile updated',
        snackPosition: SnackPosition.BOTTOM,
      );
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
            const SizedBox(height: 24),

            // Spicy Level Section
            EditProfileSpicyLevelSection(
              initialLevel: spicyLevel,
              onLevelChanged: (level) => setState(() => spicyLevel = level),
            ),
            const SizedBox(height: 24),

            // Favorite Cuisines Section
            EditProfileCuisinesSection(
              initialCuisines: selectedCuisines,
              cuisineOptions: cuisineOptions,
              onCuisinesChanged: (cuisines) =>
                  setState(() => selectedCuisines = cuisines),
            ),
            const SizedBox(height: 24),

            // Allergies Section
            EditProfileAllergiesSection(
              initialAllergies: selectedAllergies,
              allergyOptions: allergyOptions,
              onAllergiesChanged: (allergies) =>
                  setState(() => selectedAllergies = allergies),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saveProfile,
                icon: const Icon(Icons.check),
                label: const Text('Save Changes'),
              ),
            ),
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
    super.dispose();
  }
}
