import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // তারিখ ফরম্যাট করার জন্য
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
  List<DailyMealPlan> weeklyPlans = [];
  final MealPlannerService _mealPlannerService = MealPlannerService();
  final GeminiService _geminiService = GeminiService();

  bool _isLoading = true;
  bool _isGenerating = false;
  Map<String, dynamic>? _additionalInfo;

  @override
  void initState() {
    super.initState();
    // আজকের বার এবং তারিখ ফরম্যাট অনুযায়ী selectedDay সেট করা
    _setInitialSelectedDay();
    _loadUserData();
  }

  void _setInitialSelectedDay() {
    final now = DateTime.now();
    // Format: Mon (2026-01-28)
    selectedDay = "${DateFormat('EEE').format(now)} (${DateFormat('yyyy-MM-dd').format(now)})";
  }

  // প্লেসহোল্ডার হিসেবে আগামী ৭ দিনের লিস্ট জেনারেট করা
  List<String> _generatePlaceholderDays() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      return "${DateFormat('EEE').format(date)} (${DateFormat('yyyy-MM-dd').format(date)})";
    });
  }

  // ইউজার ডেটা লোড করা এবং Firebase থেকে মিল প্ল্যান লোড করা
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

        // Firebase থেকে মিল প্ল্যান লোড করার চেষ্টা করা
        final savedPlans = await _mealPlannerService.loadMealPlanFromFirebase();
        if (savedPlans != null && savedPlans.isNotEmpty && mounted) {
          setState(() {
            weeklyPlans = savedPlans;
            selectedDay = savedPlans.first.day;
          });
          debugPrint('✅ Loaded meal plan from Firebase');
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
      EasyLoading.show(status: 'Generating meal plan...');

      int targetCalories = 2000;
      if (_additionalInfo != null) {
        final goal = _additionalInfo!['primaryGoal'];
        if (goal == 'Weight Loss') targetCalories = 1800;
        else if (goal == 'Muscle Gain') targetCalories = 2400;
      }

      final generatedPlans = await _mealPlannerService.generateWeeklyMealPlan(
        userProfile: _additionalInfo,
        dietaryPreferences: _additionalInfo?['dietaryPreferences'] != null
            ? List<String>.from(_additionalInfo!['dietaryPreferences'])
            : null,
        allergies: _additionalInfo?['allergies'] != null
            ? List<String>.from(_additionalInfo!['allergies'])
            : null,
        targetCalories: targetCalories,
      );

      if (mounted && generatedPlans.isNotEmpty) {
        setState(() {
          weeklyPlans = generatedPlans;
          // জেনারেট হওয়ার পর প্রথম দিনটি অটো-সিলেক্ট করা
          selectedDay = generatedPlans.first.day;
        });
        EasyLoading.showSuccess('Meal plan generated successfully!', duration: Duration(seconds: 2));
      }
    } catch (e) {
      debugPrint('Error: $e');
      EasyLoading.showError('Failed to generate meal plan');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  DailyMealPlan? get currentDayPlan {
    if (weeklyPlans.isEmpty) return null;
    return weeklyPlans.firstWhereOrNull((plan) => plan.day == selectedDay);
  }

  Future<void> _viewMealRecipe(MealModel meal) async {
    try {
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

            // আপডেট করা ডায়নামিক DaySelector
            DaySelector(
              days: weeklyPlans.isNotEmpty 
                  ? weeklyPlans.map((p) => p.day).toList() 
                  : _generatePlaceholderDays(),
              selectedDay: selectedDay,
              onDaySelected: (day) => setState(() => selectedDay = day),
            ),

            const SizedBox(height: 24),

            if (currentPlan == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No meal plan generated for $selectedDay.\nTap "Generate" to start!',
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