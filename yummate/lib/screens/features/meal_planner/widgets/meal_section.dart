import 'package:flutter/material.dart';
import 'package:yummate/models/meal_plan_model.dart';
import 'meal_card.dart';

class MealSection extends StatelessWidget {
  final String title;
  final String emoji;
  final List<MealModel> meals;
  final Function(MealModel) onMealTapped;

  const MealSection({
    super.key,
    required this.title,
    required this.emoji,
    required this.meals,
    required this.onMealTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade300, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...meals.map((meal) => MealCard(
          meal: meal,
          onTap: () => onMealTapped(meal),
        )),
      ],
    );
  }
}
