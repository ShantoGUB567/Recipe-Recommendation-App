import 'package:flutter/material.dart';
import 'package:yummate/core/theme/app_colors.dart';

/// 🍟 Main soft UI button used across Yummate
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final buttonColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final disabledColor = Colors.grey[400]!;
    final shadowColor =
        isDark ? AppColors.darkShadow : AppColors.lightShadow;
    
    // Text color changes based on button state
    final textColor = isEnabled ? Colors.white : Colors.grey[700]!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isEnabled ? shadowColor : Colors.grey[200]!,
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? buttonColor : disabledColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
        ),
        onPressed: (isLoading || !isEnabled) ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
