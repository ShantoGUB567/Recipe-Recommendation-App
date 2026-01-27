import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/models/recipe_model.dart';
import 'package:yummate/screens/features/recipe_details/screen/recipe_details_screen.dart';
import 'info_chip.dart';
import 'recipe_stat.dart';

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final int index;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => RecipeDetailsScreen(recipe: recipe)),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Recipe Number
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF6B35),
                            Colors.orange.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Recipe Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Info Chips Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoChip(
                      icon: Icons.access_time,
                      text: recipe.preparationTime,
                      bgColor: Colors.blue.shade50,
                      textColor: Colors.blue.shade700,
                    ),
                    InfoChip(
                      icon: Icons.local_fire_department,
                      text: recipe.calories,
                      bgColor: Colors.red.shade50,
                      textColor: Colors.red.shade700,
                    ),
                    InfoChip(
                      icon: Icons.people,
                      text: recipe.servings,
                      bgColor: Colors.purple.shade50,
                      textColor: Colors.purple.shade700,
                    ),
                  ],
                ),

                if (recipe.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    recipe.description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 16),

                // Bottom Stats
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RecipeStat(
                        icon: Icons.restaurant_menu,
                        value: '${recipe.ingredients.length}',
                        label: 'Ingredients',
                        color: Colors.orange.shade700,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.orange.shade200,
                      ),
                      RecipeStat(
                        icon: Icons.list_alt,
                        value: '${recipe.instructions.length}',
                        label: 'Steps',
                        color: Colors.orange.shade700,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
