class MealModel {
  final String id;
  final String name;
  final int calories;
  final String category; // breakfast, lunch, dinner
  final String benefits;
  final String imageUrl;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String servings;
  final String preparationTime;

  MealModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.category,
    required this.benefits,
    this.imageUrl = '',
    this.description = '',
    this.ingredients = const [],
    this.instructions = const [],
    this.servings = '4',
    this.preparationTime = '30 min',
  });
}

class DailyMealPlan {
  final String day; // Mon, Tue, Wed, etc
  final List<MealModel> meals;

  DailyMealPlan({required this.day, required this.meals});

  int get totalCalories {
    return meals.fold(0, (sum, meal) => sum + meal.calories);
  }
}
