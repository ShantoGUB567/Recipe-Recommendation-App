import 'recipe_model.dart';

class SavedRecipeModel {
  final String id; // Unique ID for the saved recipe
  final String userId; // User who saved the recipe
  final RecipeModel recipe;
  final DateTime savedAt;

  SavedRecipeModel({
    required this.id,
    required this.userId,
    required this.recipe,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'recipe': recipe.toJson(),
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory SavedRecipeModel.fromJson(Map<String, dynamic> json) {
    return SavedRecipeModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      recipe: RecipeModel.fromJson(json['recipe'] ?? {}),
      savedAt: DateTime.parse(json['savedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
