import 'package:flutter/material.dart';
import 'generate_recipe_screen.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailsScreen({Key? key, required this.recipe}) : super(key: key);

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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  recipe.imageUrl,
                  width: 250,
                  height: 180,
                  fit: BoxFit.cover,
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
                Chip(label: Text('Time: ${recipe.prepareTime}')),
                Chip(label: Text('Calorie: ${recipe.calorie}')),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              recipe.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text('Ingredients', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...recipe.ingredients.map((ing) => ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(ing),
                )),
            const SizedBox(height: 16),
            Text('Steps', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...recipe.steps.asMap().entries.map((entry) => ListTile(
                  leading: CircleAvatar(child: Text('${entry.key + 1}')),
                  title: Text(entry.value),
                )),
          ],
        ),
      ),
    );
  }
}
