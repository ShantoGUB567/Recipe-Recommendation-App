import 'package:flutter/material.dart';

class EditProfileBasicInfoSection extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController usernameController;

  const EditProfileBasicInfoSection({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.usernameController,
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'Enter name',
          ),
        ),
        const SizedBox(height: 16),

        // Username
        const Text(
          'Username',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.usernameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'Enter phone number',
          ),
        ),
      ],
    );
  }
}
