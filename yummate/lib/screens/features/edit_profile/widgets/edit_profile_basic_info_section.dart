import 'package:flutter/material.dart';

class EditProfileBasicInfoSection extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController usernameController;
  final TextEditingController? bioController;
  final TextEditingController? locationController;
  final TextEditingController? specialtyDishesController;
  final TextEditingController? foodPhilosophyController;
  final String? cookingLevel;
  final Function(String?)? onCookingLevelChanged;

  const EditProfileBasicInfoSection({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.usernameController,
    this.bioController,
    this.locationController,
    this.specialtyDishesController,
    this.foodPhilosophyController,
    this.cookingLevel,
    this.onCookingLevelChanged,
  });

  @override
  State<EditProfileBasicInfoSection> createState() =>
      _EditProfileBasicInfoSectionState();
}

class _EditProfileBasicInfoSectionState
    extends State<EditProfileBasicInfoSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        const Text('Name', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: widget.nameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Enter name',
          ),
        ),
        const SizedBox(height: 16),

        // Username
        const Text('Username', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: widget.usernameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Enter username',
          ),
        ),
        const SizedBox(height: 16),

        // Email
        const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: widget.emailController,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        ),
        const SizedBox(height: 16),

        // Phone
        const Text('Phone', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: widget.phoneController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Enter phone number',
          ),
        ),
        const SizedBox(height: 16),

        // Location
        const Text('Location', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: widget.locationController ?? TextEditingController(),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'City, Country',
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
        ),
        const SizedBox(height: 16),

        // Bio
        const Text('Bio', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: widget.bioController ?? TextEditingController(),
          maxLines: 3,
          maxLength: 150,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Tell others about your cooking journey...',
          ),
        ),
        const SizedBox(height: 16),

        // Cooking Level
        const Text(
          'Cooking Level',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: widget.cookingLevel,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.local_dining_outlined),
          ),
          hint: const Text('Select your cooking level'),
          items: const [
            DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
            DropdownMenuItem(
              value: 'Intermediate',
              child: Text('Intermediate'),
            ),
            DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
            DropdownMenuItem(value: 'Expert', child: Text('Expert/Chef')),
          ],
          onChanged: widget.onCookingLevelChanged,
        ),
        const SizedBox(height: 16),

        // Specialty Dishes
        const Text(
          'Signature Dishes',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller:
              widget.specialtyDishesController ?? TextEditingController(),
          maxLines: 2,
          maxLength: 100,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'e.g., Beef Wellington, Thai Green Curry',
            prefixIcon: const Icon(Icons.stars_outlined),
          ),
        ),
        const SizedBox(height: 16),

        // Food Philosophy
        const Text(
          'Food Philosophy',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller:
              widget.foodPhilosophyController ?? TextEditingController(),
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Your cooking approach and beliefs...',
            prefixIcon: const Icon(Icons.lightbulb_outline),
          ),
        ),
      ],
    );
  }
}
