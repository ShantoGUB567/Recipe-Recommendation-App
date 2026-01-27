import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isFilled;

  const CircularButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isFilled ? color : Colors.white,
              shape: BoxShape.circle,
              border: isFilled ? null : Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isFilled ? Colors.white : color,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isFilled ? color : Colors.grey.shade700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
