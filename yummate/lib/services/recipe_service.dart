import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:yummate/models/recipe_model.dart';
import 'package:yummate/models/saved_recipe_model.dart';
import 'package:yummate/models/recipe_history_model.dart';

class RecipeService {
  static final RecipeService _instance = RecipeService._internal();
  factory RecipeService() => _instance;
  RecipeService._internal();

  final _db = FirebaseDatabase.instance.ref();
  static const uuid = Uuid();

  // ========== Saved Recipes ==========
  
  /// Save a recipe for the current user
  Future<void> saveRecipe({
    required String userId,
    required RecipeModel recipe,
  }) async {
    try {
      final recipeId = uuid.v4();
      final savedRecipe = SavedRecipeModel(
        id: recipeId,
        userId: userId,
        recipe: recipe.copyWith(id: recipeId),
        savedAt: DateTime.now(),
      );

      await _db
          .child('users')
          .child(userId)
          .child('saved_recipes')
          .child(recipeId)
          .set(savedRecipe.toJson());
    } catch (e) {
      throw Exception('Error saving recipe: $e');
    }
  }

  /// Remove a saved recipe
  Future<void> removeSavedRecipe({
    required String userId,
    required String recipeId,
  }) async {
    try {
      await _db
          .child('users')
          .child(userId)
          .child('saved_recipes')
          .child(recipeId)
          .remove();
    } catch (e) {
      throw Exception('Error removing saved recipe: $e');
    }
  }

  /// Get all saved recipes for a user
  Future<List<SavedRecipeModel>> getSavedRecipes(String userId) async {
    try {
      final snapshot = await _db
          .child('users')
          .child(userId)
          .child('saved_recipes')
          .get();

      if (!snapshot.exists) return [];

      final recipes = <SavedRecipeModel>[];
      final data = snapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        recipes.add(SavedRecipeModel.fromJson(
          Map<String, dynamic>.from(value as Map),
        ));
      });

      return recipes;
    } catch (e) {
      throw Exception('Error fetching saved recipes: $e');
    }
  }

  /// Check if a recipe is saved
  Future<bool> isRecipeSaved({
    required String userId,
    required String recipeName,
  }) async {
    try {
      final snapshot = await _db
          .child('users')
          .child(userId)
          .child('saved_recipes')
          .get();

      if (!snapshot.exists) return false;

      final data = snapshot.value as Map<dynamic, dynamic>;
      
      for (var entry in data.entries) {
        final recipe = (entry.value as Map)['recipe'] as Map<dynamic, dynamic>;
        if (recipe['name'] == recipeName) {
          return true;
        }
      }
      return false;
    } catch (e) {
      throw Exception('Error checking if recipe is saved: $e');
    }
  }

  // ========== Recipe History ==========

  /// Save a recipe history entry (search or generate)
  Future<String> saveRecipeHistory({
    required String userId,
    required String query,
    required String type, // "search" or "generate"
    required List<RecipeModel> recipes, // 3 recipes
  }) async {
    try {
      final historyId = uuid.v4();
      final history = RecipeHistoryEntry(
        id: historyId,
        userId: userId,
        query: query,
        type: type,
        recipes: recipes,
        createdAt: DateTime.now(),
      );

      await _db
          .child('users')
          .child(userId)
          .child('recipe_history')
          .child(historyId)
          .set(history.toJson());

      return historyId;
    } catch (e) {
      throw Exception('Error saving recipe history: $e');
    }
  }

  /// Get all recipe history for a user
  Future<List<RecipeHistoryEntry>> getRecipeHistory(String userId) async {
    try {
      final snapshot = await _db
          .child('users')
          .child(userId)
          .child('recipe_history')
          .orderByChild('createdAt')
          .get();

      if (!snapshot.exists) return [];

      final history = <RecipeHistoryEntry>[];
      final data = snapshot.value as Map<dynamic, dynamic>;
      
      // Sort by date descending (most recent first)
      final entries = data.entries.toList();
      entries.sort((a, b) {
        final timeA = DateTime.parse(
          (a.value as Map)['createdAt']?.toString() ?? '',
        );
        final timeB = DateTime.parse(
          (b.value as Map)['createdAt']?.toString() ?? '',
        );
        return timeB.compareTo(timeA);
      });

      for (var entry in entries) {
        history.add(RecipeHistoryEntry.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        ));
      }

      return history;
    } catch (e) {
      throw Exception('Error fetching recipe history: $e');
    }
  }

  /// Get recipe history by type (search or generate)
  Future<List<RecipeHistoryEntry>> getRecipeHistoryByType({
    required String userId,
    required String type, // "search" or "generate"
  }) async {
    try {
      final allHistory = await getRecipeHistory(userId);
      return allHistory.where((entry) => entry.type == type).toList();
    } catch (e) {
      throw Exception('Error fetching recipe history by type: $e');
    }
  }

  /// Delete a recipe history entry
  Future<void> deleteRecipeHistory({
    required String userId,
    required String historyId,
  }) async {
    try {
      await _db
          .child('users')
          .child(userId)
          .child('recipe_history')
          .child(historyId)
          .remove();
    } catch (e) {
      throw Exception('Error deleting recipe history: $e');
    }
  }

  /// Clear all recipe history for a user
  Future<void> clearAllRecipeHistory(String userId) async {
    try {
      await _db
          .child('users')
          .child(userId)
          .child('recipe_history')
          .remove();
    } catch (e) {
      throw Exception('Error clearing recipe history: $e');
    }
  }

  /// Stream saved recipes for real-time updates
  Stream<List<SavedRecipeModel>> streamSavedRecipes(String userId) {
    return _db
        .child('users')
        .child(userId)
        .child('saved_recipes')
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return [];

      final recipes = <SavedRecipeModel>[];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        recipes.add(SavedRecipeModel.fromJson(
          Map<String, dynamic>.from(value as Map),
        ));
      });

      return recipes;
    });
  }

  /// Stream recipe history for real-time updates
  Stream<List<RecipeHistoryEntry>> streamRecipeHistory(String userId) {
    return _db
        .child('users')
        .child(userId)
        .child('recipe_history')
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return [];

      final history = <RecipeHistoryEntry>[];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      
      data.forEach((key, value) {
        history.add(RecipeHistoryEntry.fromJson(
          Map<String, dynamic>.from(value as Map),
        ));
      });

      // Sort by date descending (most recent first)
      history.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return history;
    });
  }
}
