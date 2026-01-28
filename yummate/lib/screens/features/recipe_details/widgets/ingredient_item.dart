import 'package:flutter/material.dart';

class IngredientItem extends StatelessWidget {
  final int index;
  final String ingredient;
  final bool isChecked;
  final VoidCallback onToggle;

  const IngredientItem({
    super.key,
    required this.index,
    required this.ingredient,
    required this.isChecked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Green circular add button
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isChecked
                    ? Colors.grey.shade400
                    : const Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isChecked ? Icons.check : Icons.add,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Ingredient text
          Expanded(
            child: Text(
              ingredient,
              style: TextStyle(
                fontSize: 15,
                color: isChecked ? Colors.grey.shade500 : Colors.black87,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                decorationColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
