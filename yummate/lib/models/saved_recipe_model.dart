import 'package:flutter/foundation.dart';
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
    try {
      return SavedRecipeModel(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        recipe: json['recipe'] != null
            ? RecipeModel.fromJson(Map<String, dynamic>.from(json['recipe']))
            : RecipeModel(
                name: 'Unknown Recipe',
                preparationTime: '0 min',
                calories: '0',
                description: '',
                ingredients: [],
                instructions: [],
              ),
        savedAt: json['savedAt'] != null
            ? DateTime.parse(json['savedAt'])
            : DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error parsing SavedRecipeModel: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }
}
