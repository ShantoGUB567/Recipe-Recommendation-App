import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:yummate/models/meal_plan_model.dart';
import 'package:yummate/models/recipe_model.dart';
import 'package:yummate/core/widgets/bottom_nav_bar.dart';
import 'package:yummate/services/meal_planner_service.dart';
import 'package:yummate/services/gemini_service.dart';
import 'package:yummate/screens/features/recipe_details/screen/recipe_details_screen.dart';
import '../widgets/day_selector.dart';
import '../widgets/ai_generation_banner.dart';
import '../widgets/meal_section.dart';
import '../widgets/daily_calorie_summary.dart';

class WeeklyMealPlannerScreen extends StatefulWidget {
  const WeeklyMealPlannerScreen({super.key});

  @override
  State<WeeklyMealPlannerScreen> createState() =>
      _WeeklyMealPlannerScreenState();
}

class _WeeklyMealPlannerScreenState extends State<WeeklyMealPlannerScreen> {
  late String selectedDay;
  late List<DailyMealPlan> weeklyPlans;
  final MealPlannerService _mealPlannerService = MealPlannerService();
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = true;
  bool _isGenerating = false;
  Map<String, dynamic>? _additionalInfo;

  @override
  void initState() {
    super.initState();
    selectedDay = 'Mon';
    weeklyPlans = [];
    _loadUserDataAndGeneratePlan();
  }

  Future<void> _loadUserDataAndGeneratePlan() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final db = FirebaseDatabase.instance.ref();

        // Load user profile data
        final profileSnapshot = await db
            .child('user_profiles/${user.uid}')
            .get();

        if (profileSnapshot.exists) {
          _additionalInfo = Map<String, dynamic>.from(
            profileSnapshot.value as Map,
          );
        }
      }

      // Don't auto-generate - just load default plans
      _initializeDefaultMealPlans();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _initializeDefaultMealPlans();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateAIMealPlan() async {
    try {
      setState(() => _isGenerating = true);

      // Show non-blocking notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Generating personalized meal plan...'),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFFFF6B35),
        ),
      );

      // Prepare user data for AI
      final dietaryPreferences = _additionalInfo?['dietaryPreferences'] != null
          ? List<String>.from(_additionalInfo!['dietaryPreferences'])
          : null;

      final allergies = _additionalInfo?['allergies'] != null
          ? List<String>.from(_additionalInfo!['allergies'])
          : null;

      // Calculate target calories based on user profile
      int targetCalories = 2000;
      if (_additionalInfo != null) {
        final goal = _additionalInfo!['primaryGoal'];
        if (goal == 'Weight Loss') {
          targetCalories = 1800;
        } else if (goal == 'Muscle Gain') {
          targetCalories = 2400;
        }
      }

      // Generate meal plan with AI
      final generatedPlans = await _mealPlannerService.generateWeeklyMealPlan(
        userProfile: _additionalInfo,
        dietaryPreferences: dietaryPreferences,
        allergies: allergies,
        targetCalories: targetCalories,
      );

      if (mounted) {
        setState(() {
          weeklyPlans = generatedPlans;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Meal plan generated successfully!'),
              ],
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error generating AI meal plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Failed to generate meal plan: ${e.toString()}'),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red.shade600,
          ),
        );
        _initializeDefaultMealPlans();
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _initializeDefaultMealPlans() {
    setState(() {
      weeklyPlans = [
        DailyMealPlan(
          day: 'Mon',
          meals: [
            MealModel(
              id: '1',
              name: 'Scrambled Eggs & Toast',
              calories: 350,
              category: 'breakfast',
              benefits: 'Protein & Calcium',
            ),
            MealModel(
              id: '2',
              name: 'Caesar Salad',
              calories: 420,
              category: 'lunch',
              benefits: 'Vegetables & Fiber',
            ),
            MealModel(
              id: '3',
              name: 'Grilled Salmon',
              calories: 520,
              category: 'dinner',
              benefits: 'Omega-3 & Protein',
            ),
          ],
        ),
        DailyMealPlan(
          day: 'Tue',
          meals: [
            MealModel(
              id: '4',
              name: 'Oatmeal with Honey',
              calories: 320,
              category: 'breakfast',
              benefits: 'Whole Grains & Fiber',
            ),
            MealModel(
              id: '5',
              name: 'Grilled Chicken & Veggies',
              calories: 540,
              category: 'lunch',
              benefits: 'Lean Protein',
            ),
            MealModel(
              id: '6',
              name: 'Mixed Berry Smoothie',
              calories: 280,
              category: 'dinner',
              benefits: 'Antioxidants',
            ),
          ],
        ),
        DailyMealPlan(
          day: 'Wed',
          meals: [
            MealModel(
              id: '7',
              name: 'Pancakes with Berries',
              calories: 380,
              category: 'breakfast',
              benefits: 'Carbs & Antioxidants',
            ),
            MealModel(
              id: '8',
              name: 'Tuna Sandwich',
              calories: 450,
              category: 'lunch',
              benefits: 'Omega-3 & Protein',
            ),
            MealModel(
              id: '9',
              name: 'Pasta Primavera',
              calories: 510,
              category: 'dinner',
              benefits: 'Carbs & Vegetables',
            ),
          ],
        ),
        DailyMealPlan(
          day: 'Thu',
          meals: [
            MealModel(
              id: '10',
              name: 'Greek Yogurt Parfait',
              calories: 290,
              category: 'breakfast',
              benefits: 'Probiotics & Protein',
            ),
            MealModel(
              id: '11',
              name: 'Quinoa Buddha Bowl',
              calories: 480,
              category: 'lunch',
              benefits: 'Complete Protein',
            ),
            MealModel(
              id: '12',
              name: 'Beef Stir-fry',
              calories: 550,
              category: 'dinner',
              benefits: 'Iron & Protein',
            ),
          ],
        ),
        DailyMealPlan(
          day: 'Fri',
          meals: [
            MealModel(
              id: '13',
              name: 'Avocado Toast',
              calories: 340,
              category: 'breakfast',
              benefits: 'Healthy Fats',
            ),
            MealModel(
              id: '14',
              name: 'Grilled Shrimp Tacos',
              calories: 420,
              category: 'lunch',
              benefits: 'Lean Protein',
            ),
            MealModel(
              id: '15',
              name: 'Chicken Curry',
              calories: 580,
              category: 'dinner',
              benefits: 'Spices & Protein',
            ),
          ],
        ),
        DailyMealPlan(
          day: 'Sat',
          meals: [
            MealModel(
              id: '16',
              name: 'French Toast',
              calories: 410,
              category: 'breakfast',
              benefits: 'Carbs & Calcium',
            ),
            MealModel(
              id: '17',
              name: 'Caprese Salad',
              calories: 380,
              category: 'lunch',
              benefits: 'Fresh Vegetables',
            ),
            MealModel(
              id: '18',
              name: 'Roasted Vegetables',
              calories: 320,
              category: 'dinner',
              benefits: 'Vitamins & Minerals',
            ),
          ],
        ),
        DailyMealPlan(
          day: 'Sun',
          meals: [
            MealModel(
              id: '19',
              name: 'Fruit Smoothie Bowl',
              calories: 300,
              category: 'breakfast',
              benefits: 'Vitamins & Fiber',
            ),
            MealModel(
              id: '20',
              name: 'Vegetable Soup',
              calories: 280,
              category: 'lunch',
              benefits: 'Nutrients & Fiber',
            ),
            MealModel(
              id: '21',
              name: 'Grilled Steak',
              calories: 620,
              category: 'dinner',
              benefits: 'Iron & Protein',
            ),
          ],
        ),
      ];
    });
  }

  DailyMealPlan get currentDayPlan {
    return weeklyPlans.firstWhere((plan) => plan.day == selectedDay);
  }

  Future<RecipeModel?> _getCachedRecipe(
    String recipeName,
    String calories,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final db = FirebaseDatabase.instance.ref();
      final snapshot = await db
          .child('generated_recipes')
          .child(user.uid)
          .get();

      if (snapshot.exists) {
        // Find exact match by name and calories
        final recipesMap = Map<String, dynamic>.from(snapshot.value as Map);
        for (var entry in recipesMap.entries) {
          final data = Map<String, dynamic>.from(entry.value as Map);
          if (data['name'] == recipeName && data['calories'] == calories) {
            return RecipeModel(
              name: data['name'] ?? recipeName,
              preparationTime: data['preparationTime'] ?? '30 min',
              calories: data['calories'] ?? calories,
              description: data['description'] ?? '',
              ingredients: List<String>.from(data['ingredients'] ?? []),
              instructions: List<String>.from(data['instructions'] ?? []),
              servings: data['servings'] ?? '4',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching cached recipe: $e');
    }
    return null;
  }

  Future<void> _saveRecipeToCache(RecipeModel recipe) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final db = FirebaseDatabase.instance.ref();
      await db.child('generated_recipes').child(user.uid).push().set({
        'name': recipe.name,
        'preparationTime': recipe.preparationTime,
        'calories': recipe.calories,
        'description': recipe.description,
        'ingredients': recipe.ingredients,
        'instructions': recipe.instructions,
        'servings': recipe.servings,
        'timestamp': ServerValue.timestamp,
      });
      debugPrint('Recipe cached: ${recipe.name}');
    } catch (e) {
      debugPrint('Error caching recipe: $e');
    }
  }

  Future<void> _viewMealRecipe(MealModel meal) async {
    try {
      // Check if meal already has recipe details saved
      if (meal.ingredients.isNotEmpty && meal.instructions.isNotEmpty) {
        debugPrint('Using saved recipe details from meal plan');
        final recipe = RecipeModel(
          name: meal.name,
          calories: '${meal.calories}',
          description: meal.description,
          ingredients: meal.ingredients,
          instructions: meal.instructions,
          servings: meal.servings,
          preparationTime: meal.preparationTime,
        );
        Get.to(
          () => RecipeDetailsScreen(recipe: recipe),
          transition: Transition.rightToLeft,
        );
        return;
      }

      EasyLoading.show(status: 'Loading recipe...');

      // Check if recipe is already cached with exact calories match
      RecipeModel? cachedRecipe = await _getCachedRecipe(
        meal.name,
        '${meal.calories}',
      );

      if (cachedRecipe != null) {
        EasyLoading.dismiss();
        debugPrint('Using cached recipe: ${meal.name}');
        Get.to(
          () => RecipeDetailsScreen(recipe: cachedRecipe),
          transition: Transition.rightToLeft,
        );
        return;
      }

      // Generate new recipe using Gemini AI with exact meal details
      EasyLoading.show(status: 'Generating recipe...');
      final recipeText = await _geminiService.searchRecipe(
        recipeName: meal.name,
        targetCalories: '${meal.calories}',
        description: meal.description,
      );

      // Parse the recipe
      final recipes = RecipeModel.parseMultipleRecipes(recipeText);

      EasyLoading.dismiss();

      if (recipes.isNotEmpty) {
        // Save to cache for future use
        await _saveRecipeToCache(recipes[0]);

        // Navigate to recipe details
        Get.to(
          () => RecipeDetailsScreen(recipe: recipes[0]),
          transition: Transition.rightToLeft,
        );
      } else {
        EasyLoading.showError('Failed to generate recipe');
      }
    } catch (e) {
      debugPrint('Error generating meal recipe: $e');
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to generate recipe');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'Weekly Meal Planner',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
        ),
      );
    }

    final currentPlan = currentDayPlan;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Weekly Meal Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Generation offer banner
            AIGenerationBanner(
              onGeneratePressed: _generateAIMealPlan,
              isGenerating: _isGenerating,
            ),

            // Week selector
            DaySelector(
              selectedDay: selectedDay,
              onDaySelected: (day) => setState(() => selectedDay = day),
            ),
            const SizedBox(height: 24),

            // Breakfast section
            MealSection(
              title: 'BREAKFAST',
              emoji: '🍳',
              meals: currentPlan.meals
                  .where((m) => m.category == 'breakfast')
                  .toList(),
              onMealTapped: _viewMealRecipe,
            ),
            const SizedBox(height: 16),

            // Lunch section
            MealSection(
              title: 'LUNCH',
              emoji: '🍲',
              meals:
                  currentPlan.meals.where((m) => m.category == 'lunch').toList(),
              onMealTapped: _viewMealRecipe,
            ),
            const SizedBox(height: 16),

            // Dinner section
            MealSection(
              title: 'DINNER',
              emoji: '🍽️',
              meals:
                  currentPlan.meals.where((m) => m.category == 'dinner').toList(),
              onMealTapped: _viewMealRecipe,
            ),
            const SizedBox(height: 24),

            // Daily total
            DailyCalorieSummary(currentPlan: currentPlan),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }


}
