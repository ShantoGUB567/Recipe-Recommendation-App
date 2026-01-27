import 'package:flutter/material.dart';

class SaveProfileButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const SaveProfileButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 22,
              color: isLoading ? Colors.grey : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isLoading ? Colors.grey : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
