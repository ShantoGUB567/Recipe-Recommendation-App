import 'package:flutter/material.dart';
import 'dart:io';

class ImagePreview extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onRemove;

  const ImagePreview({
    super.key,
    this.selectedImage,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedImage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              selectedImage!,
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.close,
                  color: Colors.black87,
                  size: 20,
                ),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
