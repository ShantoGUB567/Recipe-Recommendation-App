import 'package:flutter/material.dart';
import 'package:yummate/models/recipe_model.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final RecipeModel recipe;
  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 250,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              recipe.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Use Wrap so chips don't overflow on small screens
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(label: Text('Time: ${recipe.preparationTime}')),
                Chip(label: Text('Calorie: ${recipe.calories}')),
              ],
            ),
            const SizedBox(height: 16),
            Text(recipe.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(
              'Ingredients',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...recipe.ingredients.map(
              (ing) => ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(ing),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Instructions',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...recipe.instructions.asMap().entries.map(
              (entry) => ListTile(
                leading: CircleAvatar(child: Text('${entry.key + 1}')),
                title: Text(entry.value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
