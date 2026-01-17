import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/create_post_screen.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const CreatePostScreen());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // User photo placeholder
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF7CB342).withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: Color(0xFF7CB342),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Text field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Share Your Kitchen's Story",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Image picker icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.image_outlined,
                color: Color(0xFF7CB342),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
