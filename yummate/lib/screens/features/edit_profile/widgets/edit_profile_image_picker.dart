import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileImagePicker extends StatefulWidget {
  final Function(File?) onImagePicked;

  const EditProfileImagePicker({super.key, required this.onImagePicked});

  @override
  State<EditProfileImagePicker> createState() => _EditProfileImagePickerState();
}

class _EditProfileImagePickerState extends State<EditProfileImagePicker> {
  File? profileImage;

  Future<void> pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => profileImage = File(image.path));
      widget.onImagePicked(profileImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}
