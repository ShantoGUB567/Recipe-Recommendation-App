import 'package:flutter/material.dart';

class AddMediaSection extends StatelessWidget {
  final VoidCallback onPhotoTapped;
  final bool hasImage;

  const AddMediaSection({
    super.key,
    required this.onPhotoTapped,
    required this.hasImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          const Text(
            'Add to your post',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          // Photo/Video button
          InkWell(
            onTap: onPhotoTapped,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: !hasImage
                    ? const Color(0xFFFF6B35).withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.image,
                    color: !hasImage
                        ? const Color(0xFFFF6B35)
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Photo',
                    style: TextStyle(
                      color: !hasImage
                          ? const Color(0xFFFF6B35)
                          : Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
