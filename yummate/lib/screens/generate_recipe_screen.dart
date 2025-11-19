import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'recipe_details_screen.dart';

class Recipe {
  final String imageUrl;
  final String name;
  final String prepareTime;
  final String calorie;
  final String description;
  final List<String> ingredients;
  final List<String> steps;

  Recipe({
    required this.imageUrl,
    required this.name,
    required this.prepareTime,
    required this.calorie,
    required this.description,
    required this.ingredients,
    required this.steps,
  });
}

final List<Recipe> recipes = [
  Recipe(
    imageUrl: 'https://picsum.photos/seed/grilledchicken/400/300',
    name: 'Grilled Chicken Salad',
    prepareTime: '20 min',
    calorie: '350 kcal',
    description: 'A healthy grilled chicken salad with fresh veggies.',
    ingredients: [
      'Chicken breast',
      'Lettuce',
      'Tomato',
      'Cucumber',
      'Olive oil',
      'Salt',
      'Pepper',
    ],
    steps: [
      'Grill the chicken breast.',
      'Chop the veggies.',
      'Mix everything together.',
      'Add olive oil, salt, and pepper.',
    ],
  ),
  Recipe(
    imageUrl: 'https://picsum.photos/seed/veggiepasta/400/300',
    name: 'Veggie Pasta',
    prepareTime: '30 min',
    calorie: '420 kcal',
    description: 'Delicious pasta loaded with fresh vegetables.',
    ingredients: [
      'Pasta',
      'Bell pepper',
      'Broccoli',
      'Carrot',
      'Tomato sauce',
      'Salt',
      'Cheese',
    ],
    steps: [
      'Boil the pasta.',
      'Cook the veggies.',
      'Mix with tomato sauce.',
      'Top with cheese.',
    ],
  ),
  Recipe(
    imageUrl: 'https://picsum.photos/seed/fruitsmoothie/400/300',
    name: 'Fruit Smoothie',
    prepareTime: '10 min',
    calorie: '180 kcal',
    description: 'A refreshing smoothie with mixed fruits.',
    ingredients: [
      'Banana',
      'Strawberry',
      'Orange',
      'Yogurt',
      'Honey',
    ],
    steps: [
      'Chop the fruits.',
      'Blend with yogurt and honey.',
      'Serve chilled.',
    ],
  ),
];

class GenerateRecipeScreen extends StatelessWidget {
  const GenerateRecipeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Recipes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return GestureDetector(
                  onTap: () => Get.to(() => RecipeDetailsScreen(recipe: recipe)),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              recipe.imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              // handle network errors gracefully
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Make title flexible and limit lines to avoid overflow
                                Text(
                                  recipe.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Flexible(child: Text('Prepare: ${recipe.prepareTime}')),
                                    const SizedBox(width: 8),
                                    Flexible(child: Text('Cal: ${recipe.calorie}')),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                if (recipe.description.isNotEmpty)
                                  Text(
                                    recipe.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // You can add logic to regenerate recipes here
                  Get.snackbar('Generate Again', 'New recipes will be generated!', snackPosition: SnackPosition.BOTTOM);
                },
                child: const Text('Generate Again'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
