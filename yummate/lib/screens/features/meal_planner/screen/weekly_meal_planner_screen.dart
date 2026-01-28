import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart'; // firstWhereOrNull এর জন্য এটি জরুরি

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
  List<DailyMealPlan> weeklyPlans = []; // Initialized as empty list
  final MealPlannerService _mealPlannerService = MealPlannerService();
  final GeminiService _geminiService = GeminiService();
  
  bool _isLoading = true;
  bool _isGenerating = false;
  Map<String, dynamic>? _additionalInfo;

  @override
  void initState() {
    super.initState();
    selectedDay = 'Mon';
    _loadUserData();
  }

  // ইউজার ডেটা লোড করা
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final db = FirebaseDatabase.instance.ref();
        final profileSnapshot = await db.child('user_profiles/${user.uid}').get();

        if (profileSnapshot.exists) {
          _additionalInfo = Map<String, dynamic>.from(profileSnapshot.value as Map);
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // AI মিল প্ল্যান জেনারেট করা
  Future<void> _generateAIMealPlan() async {
    try {
      setState(() => _isGenerating = true);

      // ক্যালোরি গোল ক্যালকুলেট করা
      int targetCalories = 2000;
      if (_additionalInfo != null) {
        final goal = _additionalInfo!['primaryGoal'];
        if (goal == 'Weight Loss') targetCalories = 1800;
        else if (goal == 'Muscle Gain') targetCalories = 2400;
      }

      final generatedPlans = await _mealPlannerService.generateWeeklyMealPlan(
        userProfile: _additionalInfo,
        dietaryPreferences: _additionalInfo?['dietaryPreferences'] != null 
            ? List<String>.from(_additionalInfo!['dietaryPreferences']) : null,
        allergies: _additionalInfo?['allergies'] != null 
            ? List<String>.from(_additionalInfo!['allergies']) : null,
        targetCalories: targetCalories,
      );

      if (mounted && generatedPlans.isNotEmpty) {
        setState(() {
          weeklyPlans = generatedPlans;
        });
        Get.snackbar(
          'Success', 'Meal plan generated successfully!',
          backgroundColor: Colors.green, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar('Error', 'Failed to generate plan', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  // নিরাপদভাবে বর্তমান দিনের প্ল্যান খুঁজে বের করা
  DailyMealPlan? get currentDayPlan {
    if (weeklyPlans.isEmpty) return null;
    return weeklyPlans.firstWhereOrNull((plan) => plan.day == selectedDay);
  }

  // রেসিপি দেখার লজিক (Cache থেকে অথবা AI দিয়ে জেনারেট)
  Future<void> _viewMealRecipe(MealModel meal) async {
    try {
      // যদি মিলে আগেই ইনগ্রেডিয়েন্ট থাকে
      if (meal.ingredients.isNotEmpty && meal.instructions.isNotEmpty) {
        final recipe = RecipeModel(
          name: meal.name,
          calories: '${meal.calories}',
          description: meal.description,
          ingredients: meal.ingredients,
          instructions: meal.instructions,
          servings: meal.servings,
          preparationTime: meal.preparationTime,
        );
        Get.to(() => RecipeDetailsScreen(recipe: recipe), transition: Transition.rightToLeft);
        return;
      }

      EasyLoading.show(status: 'Fetching recipe...');
      // Gemini AI থেকে রেসিপি সার্চ/জেনারেট করা
      final recipeText = await _geminiService.searchRecipe(
        recipeName: meal.name,
        targetCalories: '${meal.calories}',
        description: meal.description,
      );

      final recipes = RecipeModel.parseMultipleRecipes(recipeText);
      EasyLoading.dismiss();

      if (recipes.isNotEmpty) {
        Get.to(() => RecipeDetailsScreen(recipe: recipes[0]), transition: Transition.rightToLeft);
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to load recipe');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Weekly Meal Planner'), backgroundColor: const Color(0xFFFF6B35)),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35))),
      );
    }

    final currentPlan = currentDayPlan;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Weekly Meal Planner', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AIGenerationBanner(
              onGeneratePressed: _generateAIMealPlan,
              isGenerating: _isGenerating,
            ),
            
            DaySelector(
              selectedDay: selectedDay,
              onDaySelected: (day) => setState(() => selectedDay = day),
            ),
            
            const SizedBox(height: 24),

            // ডাটা না থাকলে ইউজারকে মেসেজ দেখানো
            if (currentPlan == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No meal plan generated yet.\nTap "Generate" to start!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              MealSection(
                title: 'BREAKFAST', emoji: '🍳',
                meals: currentPlan.meals.where((m) => m.category == 'breakfast').toList(),
                onMealTapped: _viewMealRecipe,
              ),
              const SizedBox(height: 16),
              MealSection(
                title: 'LUNCH', emoji: '🍲',
                meals: currentPlan.meals.where((m) => m.category == 'lunch').toList(),
                onMealTapped: _viewMealRecipe,
              ),
              const SizedBox(height: 16),
              MealSection(
                title: 'DINNER', emoji: '🍽️',
                meals: currentPlan.meals.where((m) => m.category == 'dinner').toList(),
                onMealTapped: _viewMealRecipe,
              ),
              const SizedBox(height: 24),
              DailyCalorieSummary(currentPlan: currentPlan),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}