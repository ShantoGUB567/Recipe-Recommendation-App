import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummate/models/recipe_model.dart';

class GeneratedRecipeSession {
  final List<RecipeModel> recipes;
  final String query;
  final DateTime timestamp;

  GeneratedRecipeSession({
    required this.recipes,
    required this.query,
    required this.timestamp,
  });
}

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  static const String _favoriteRecipesKey = 'favorite_recipes';
  static const String _recentRecipesKey = 'recent_recipes';
  static const String _searchHistoryKey = 'search_history';
  static const String _userPreferencesKey = 'user_preferences';
  static const String _checkedIngredientsKey = 'checked_ingredients';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _userIdKey = 'user_id';
  static const String _loginTimestampKey = 'login_timestamp';
  static const String _generatedRecipesKey = 'generated_recipes';

  SharedPreferences? _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Ensure preferences are initialized
  Future<SharedPreferences> get prefs async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ========== Favorite Recipes ==========
  Future<void> saveFavoriteRecipe(RecipeModel recipe) async {
    final preferences = await prefs;
    final favorites = await getFavoriteRecipes();

    // Check if recipe already exists
    if (!favorites.any((r) => r.name == recipe.name)) {
      favorites.add(recipe);
      final jsonList = favorites.map((r) => r.toJson()).toList();
      await preferences.setString(_favoriteRecipesKey, jsonEncode(jsonList));
    }
  }

  Future<void> removeFavoriteRecipe(String recipeName) async {
    final preferences = await prefs;
    final favorites = await getFavoriteRecipes();
    favorites.removeWhere((r) => r.name == recipeName);
    final jsonList = favorites.map((r) => r.toJson()).toList();
    await preferences.setString(_favoriteRecipesKey, jsonEncode(jsonList));
  }

  Future<List<RecipeModel>> getFavoriteRecipes() async {
    final preferences = await prefs;
    final jsonString = preferences.getString(_favoriteRecipesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => RecipeModel.fromJson(json)).toList();
  }

  Future<bool> isFavorite(String recipeName) async {
    final favorites = await getFavoriteRecipes();
    return favorites.any((r) => r.name == recipeName);
  }

  // ========== Recent Recipes ==========
  Future<void> saveRecentRecipe(RecipeModel recipe) async {
    final preferences = await prefs;
    final recent = await getRecentRecipes();

    // Remove if already exists
    recent.removeWhere((r) => r.name == recipe.name);

    // Add to beginning
    recent.insert(0, recipe);

    // Keep only last 20 recipes
    if (recent.length > 20) {
      recent.removeRange(20, recent.length);
    }

    final jsonList = recent.map((r) => r.toJson()).toList();
    await preferences.setString(_recentRecipesKey, jsonEncode(jsonList));
  }

  Future<List<RecipeModel>> getRecentRecipes() async {
    final preferences = await prefs;
    final jsonString = preferences.getString(_recentRecipesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => RecipeModel.fromJson(json)).toList();
  }

  Future<void> clearRecentRecipes() async {
    final preferences = await prefs;
    await preferences.remove(_recentRecipesKey);
  }

  // ========== Search History ==========
  Future<void> saveSearchQuery(String query) async {
    final preferences = await prefs;
    final history = await getSearchHistory();

    // Remove if already exists
    history.remove(query);

    // Add to beginning
    history.insert(0, query);

    // Keep only last 10 searches
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    await preferences.setStringList(_searchHistoryKey, history);
  }

  Future<List<String>> getSearchHistory() async {
    final preferences = await prefs;
    return preferences.getStringList(_searchHistoryKey) ?? [];
  }

  Future<void> clearSearchHistory() async {
    final preferences = await prefs;
    await preferences.remove(_searchHistoryKey);
  }

  // ========== User Preferences ==========
  Future<void> saveUserPreference(String key, dynamic value) async {
    final preferences = await prefs;
    final userPrefs = await getUserPreferences();
    userPrefs[key] = value;
    await preferences.setString(_userPreferencesKey, jsonEncode(userPrefs));
  }

  Future<Map<String, dynamic>> getUserPreferences() async {
    final preferences = await prefs;
    final jsonString = preferences.getString(_userPreferencesKey);
    if (jsonString == null) return {};
    return jsonDecode(jsonString);
  }

  Future<dynamic> getUserPreference(String key) async {
    final userPrefs = await getUserPreferences();
    return userPrefs[key];
  }

  // ========== Checked Ingredients ==========
  Future<void> saveCheckedIngredients(
    String recipeName,
    Set<int> checkedIndices,
  ) async {
    final preferences = await prefs;
    final allChecked = await getAllCheckedIngredients();
    allChecked[recipeName] = checkedIndices.toList();
    await preferences.setString(_checkedIngredientsKey, jsonEncode(allChecked));
  }

  Future<Set<int>> getCheckedIngredients(String recipeName) async {
    final allChecked = await getAllCheckedIngredients();
    final list = allChecked[recipeName] as List<dynamic>?;
    return list?.map((e) => e as int).toSet() ?? {};
  }

  Future<Map<String, dynamic>> getAllCheckedIngredients() async {
    final preferences = await prefs;
    final jsonString = preferences.getString(_checkedIngredientsKey);
    if (jsonString == null) return {};
    return jsonDecode(jsonString);
  }

  // ========== Generated Recipe Sessions ==========
  Future<void> saveGeneratedRecipeSession({
    required List<RecipeModel> recipes,
    required String query,
  }) async {
    final preferences = await prefs;
    final sessions = await getGeneratedRecipeSessions();

    // Create session object
    final session = {
      'recipes': recipes.map((r) => r.toJson()).toList(),
      'query': query,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Add to beginning
    sessions.insert(0, session);

    // Keep only last 50 sessions
    if (sessions.length > 50) {
      sessions.removeRange(50, sessions.length);
    }

    await preferences.setString(_generatedRecipesKey, jsonEncode(sessions));
  }

  Future<List<Map<String, dynamic>>> getGeneratedRecipeSessions() async {
    final preferences = await prefs;
    final jsonString = preferences.getString(_generatedRecipesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> clearGeneratedRecipeSessions() async {
    final preferences = await prefs;
    await preferences.remove(_generatedRecipesKey);
  }

  // Get parsed recipe sessions
  Future<List<GeneratedRecipeSession>> getParsedRecipeSessions() async {
    final sessions = await getGeneratedRecipeSessions();
    return sessions.map((session) {
      final recipes = (session['recipes'] as List<dynamic>)
          .map((r) => RecipeModel.fromJson(r))
          .toList();
      return GeneratedRecipeSession(
        recipes: recipes,
        query: session['query'] as String,
        timestamp: DateTime.parse(session['timestamp'] as String),
      );
    }).toList();
  }

  // ========== Login Session Management ==========
  Future<void> saveLoginSession({
    required String userId,
    required String email,
  }) async {
    final preferences = await prefs;
    await preferences.setBool(_isLoggedInKey, true);
    await preferences.setString(_userEmailKey, email);
    await preferences.setString(_userIdKey, userId);
    await preferences.setString(
      _loginTimestampKey,
      DateTime.now().toIso8601String(),
    );
  }

  Future<bool> isLoggedIn() async {
    final preferences = await prefs;
    return preferences.getBool(_isLoggedInKey) ?? false;
  }

  Future<String?> getUserEmail() async {
    final preferences = await prefs;
    return preferences.getString(_userEmailKey);
  }

  Future<String?> getUserId() async {
    final preferences = await prefs;
    return preferences.getString(_userIdKey);
  }

  Future<DateTime?> getLoginTimestamp() async {
    final preferences = await prefs;
    final timestamp = preferences.getString(_loginTimestampKey);
    if (timestamp == null) return null;
    return DateTime.parse(timestamp);
  }

  Future<void> logout() async {
    final preferences = await prefs;
    await preferences.remove(_isLoggedInKey);
    await preferences.remove(_userEmailKey);
    await preferences.remove(_userIdKey);
    await preferences.remove(_loginTimestampKey);
  }

  // ========== Clear All Data ==========
  Future<void> clearAllData() async {
    final preferences = await prefs;
    await preferences.clear();
  }
}
