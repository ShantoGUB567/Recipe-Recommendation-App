import 'recipe_model.dart';

class RecipeHistoryEntry {
  final String id; // Unique ID for this search/generate entry
  final String userId;
  final String query; // Search query or "generated"
  final String type; // "search" or "generate"
  final List<RecipeModel> recipes; // 3 recipes
  final DateTime createdAt;

  RecipeHistoryEntry({
    required this.id,
    required this.userId,
    required this.query,
    required this.type,
    required this.recipes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'query': query,
      'type': type,
      'recipes': recipes.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RecipeHistoryEntry.fromJson(Map<String, dynamic> json) {
    return RecipeHistoryEntry(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      query: json['query'] ?? '',
      type: json['type'] ?? 'generate',
      recipes: (json['recipes'] as List<dynamic>?)
          ?.map((r) => RecipeModel.fromJson(r as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
