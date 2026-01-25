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
import 'package:yummate/screens/recipe_details_screen.dart';

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
            // AI Generation offer banner (only show if not generating)
            if (!_isGenerating)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Want a Personalized Plan?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Generate with AI based on your profile',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _generateAIMealPlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF6B35),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Generate',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Generating indicator banner
            if (_isGenerating)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'AI is generating your personalized meal plan...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'You can navigate away',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            // Week selector header
            const Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFFFF6B35), size: 20),
                SizedBox(width: 8),
                Text(
                  'Select Day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Week selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .map(
                      (day) => GestureDetector(
                        onTap: () {
                          setState(() => selectedDay = day);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: selectedDay == day
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFFF6B35),
                                      Color(0xFFFF8C42),
                                    ],
                                  )
                                : null,
                            color: selectedDay == day ? null : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedDay == day
                                  ? Colors.transparent
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            boxShadow: selectedDay == day
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF6B35,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedDay == day
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Breakfast section
            _buildMealSection(
              'BREAKFAST',
              '🍳',
              currentPlan.meals
                  .where((m) => m.category == 'breakfast')
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Lunch section
            _buildMealSection(
              'LUNCH',
              '🍲',
              currentPlan.meals.where((m) => m.category == 'lunch').toList(),
            ),
            const SizedBox(height: 16),

            // Dinner section
            _buildMealSection(
              'DINNER',
              '🍽️',
              currentPlan.meals.where((m) => m.category == 'dinner').toList(),
            ),
            const SizedBox(height: 24),

            // Daily total
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Calories',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${currentPlan.totalCalories} kcal',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'On Track',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildMealSection(String title, String emoji, List<MealModel> meals) {
    if (meals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade300, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...meals.map((meal) => _buildMealCard(meal)),
      ],
    );
  }

  Widget _buildMealCard(MealModel meal) {
    Color categoryColor;
    IconData categoryIcon;

    switch (meal.category) {
      case 'breakfast':
        categoryColor = const Color(0xFFFFA726);
        categoryIcon = Icons.breakfast_dining;
        break;
      case 'lunch':
        categoryColor = const Color(0xFF66BB6A);
        categoryIcon = Icons.lunch_dining;
        break;
      case 'dinner':
        categoryColor = const Color(0xFF42A5F5);
        categoryIcon = Icons.dinner_dining;
        break;
      default:
        categoryColor = const Color(0xFF7CB342);
        categoryIcon = Icons.restaurant;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _viewMealRecipe(meal),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Meal icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor,
                        categoryColor.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(categoryIcon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),

                // Meal info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${meal.calories} kcal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          meal.benefits,
                          style: TextStyle(
                            fontSize: 10,
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
