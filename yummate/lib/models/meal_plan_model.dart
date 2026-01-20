class MealModel {
  final String id;
  final String name;
  final int calories;
  final String category; // breakfast, lunch, dinner
  final String benefits;
  final String imageUrl;

  MealModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.category,
    required this.benefits,
    this.imageUrl = '',
  });
}

class DailyMealPlan {
  final String day; // Mon, Tue, Wed, etc
  final List<MealModel> meals;

  DailyMealPlan({
    required this.day,
    required this.meals,
  });

  int get totalCalories {
    return meals.fold(0, (sum, meal) => sum + meal.calories);
  }
}
