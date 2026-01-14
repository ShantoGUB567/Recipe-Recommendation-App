class RecipeModel {
  final String name;
  final String preparationTime;
  final String calories;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String? imageUrl;
  final String servings;

  RecipeModel({
    required this.name,
    required this.preparationTime,
    required this.calories,
    required this.description,
    required this.ingredients,
    required this.instructions,
    this.imageUrl,
    this.servings = '4',
  });

  static List<RecipeModel> parseMultipleRecipes(String response) {
    final recipeSections = response.split('---');
    final recipes = <RecipeModel>[];

    for (var section in recipeSections) {
      if (section.trim().isNotEmpty) {
        try {
          final recipe = RecipeModel.fromGeminiResponse(section);
          // Only add if it's not a default/failed parse
          if (recipe.name != 'Delicious Recipe' ||
              recipe.ingredients.isNotEmpty) {
            recipes.add(recipe);
          }
        } catch (e) {
          // Skip invalid sections
          continue;
        }
      }
    }

    return recipes.isEmpty
        ? [RecipeModel.fromGeminiResponse(response)]
        : recipes;
  }

  factory RecipeModel.fromGeminiResponse(String response) {
    try {
      // Parse the formatted response from Gemini
      final lines = response.split('\n');

      String? name;
      String prepTime = '30 min';
      String calories = '350 kcal';
      String description = '';
      String servings = '4';
      List<String> ingredients = [];
      List<String> instructions = [];

      String currentSection = '';

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;

        // Remove markdown formatting
        line = line.replaceAll('**', '').replaceAll('*', '');

        if (line.startsWith('Recipe Name:')) {
          name = line.replaceFirst('Recipe Name:', '').trim();
        } else if (line.startsWith('Preparation Time:')) {
          prepTime = line.replaceFirst('Preparation Time:', '').trim();
        } else if (line.startsWith('Calories:')) {
          calories = line.replaceFirst('Calories:', '').trim();
        } else if (line.startsWith('Servings:')) {
          servings = line.replaceFirst('Servings:', '').trim();
        } else if (line.startsWith('Description:')) {
          description = line.replaceFirst('Description:', '').trim();
        } else if (line.startsWith('Ingredients:')) {
          currentSection = 'ingredients';
        } else if (line.startsWith('Instructions:')) {
          currentSection = 'instructions';
        } else if (currentSection == 'ingredients' &&
            (line.startsWith('-') || line.startsWith('•'))) {
          ingredients.add(line.substring(1).trim());
        } else if (currentSection == 'instructions') {
          // Remove numbering like "1.", "2." etc
          final instruction = line
              .replaceFirst(RegExp(r'^\d+\.?\s*'), '')
              .trim();
          if (instruction.isNotEmpty) {
            instructions.add(instruction);
          }
        } else if (currentSection == 'ingredients' && line.isNotEmpty) {
          // Skip section headers like "For Rice:", "For Chicken:", etc.
          if (!line.endsWith(':') && !line.contains('For ')) {
            // Handle ingredients without bullet points
            ingredients.add(line);
          }
        } else if (currentSection == 'description' && line.isNotEmpty) {
          description += ' $line';
        }
      }

      // If no name was found, skip this recipe (return a placeholder that will be filtered)
      if (name == null || name.isEmpty) {
        throw Exception('No recipe name found');
      }

      return RecipeModel(
        name: name,
        preparationTime: prepTime,
        calories: calories,
        description: description.trim(),
        ingredients: ingredients,
        instructions: instructions,
        servings: servings,
      );
    } catch (e) {
      // Return a fallback recipe if parsing fails
      throw Exception('Failed to parse recipe');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'preparationTime': preparationTime,
      'calories': calories,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'servings': servings,
    };
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      name: json['name'] ?? 'Recipe',
      preparationTime: json['preparationTime'] ?? '30 min',
      calories: json['calories'] ?? '350 kcal',
      description: json['description'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      imageUrl: json['imageUrl'],
      servings: json['servings'] ?? '4',
    );
  }
}
