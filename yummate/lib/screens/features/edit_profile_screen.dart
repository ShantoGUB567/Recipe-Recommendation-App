import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String uid;

  const EditProfileScreen({
    Key? key,
    required this.userData,
    required this.uid,
  }) : super(key: key);

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

  final List<String> cuisineOptions = ['Bangladeshi', 'Indian', 'Chinese', 'Italian', 'Thai', 'Mexican', 'American'];
  final List<String> allergyOptions = ['Peanuts', 'Dairy', 'Gluten', 'Shellfish', 'Eggs', 'Tree Nuts'];

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userData['name'] ?? '');
    emailController = TextEditingController(text: widget.userData['email'] ?? '');
    phoneController = TextEditingController(text: widget.userData['phone'] ?? '');
    usernameController = TextEditingController(text: widget.userData['username'] ?? '');
    spicyLevel = widget.userData['spicy_level'] ?? 2;
    selectedCuisines = List<String>.from(widget.userData['favorite_cuisines'] ?? []);
    selectedAllergies = List<String>.from(widget.userData['allergies'] ?? []);
  }

  Future<void> pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => profileImage = File(image.path));
    }
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
      Get.snackbar('Success', 'Profile updated', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e', snackPosition: SnackPosition.BOTTOM);
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
                      ? ClipOval(child: Image.file(profileImage!, fit: BoxFit.cover))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt, color: Colors.orange, size: 32),
                            SizedBox(height: 4),
                            Text('Change Photo', style: TextStyle(fontSize: 12)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'Enter name',
              ),
            ),
            const SizedBox(height: 16),

            // Username
            Text('Username', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'Enter phone number',
              ),
            ),
            const SizedBox(height: 24),

            // Spicy Level
            Text('Spicy Level', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
                      Text('$spicyLevel', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text('🌶️🌶️🌶️ Very Hot'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: spicyLevel.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (value) => setState(() => spicyLevel = value.toInt()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Favorite Cuisines
            Text('Favorite Cuisines', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
            Text('Allergies', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
