import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:yummate/models/meal_plan_model.dart';
import 'package:yummate/core/widgets/bottom_nav_bar.dart';

class WeeklyMealPlannerScreen extends StatefulWidget {
  const WeeklyMealPlannerScreen({super.key});

  @override
  State<WeeklyMealPlannerScreen> createState() =>
      _WeeklyMealPlannerScreenState();
}

class _WeeklyMealPlannerScreenState extends State<WeeklyMealPlannerScreen> {
  late String selectedDay;
  late List<DailyMealPlan> weeklyPlans;

  @override
  void initState() {
    super.initState();
    selectedDay = 'Tue';
    _initializeMealPlans();
  }

  void _initializeMealPlans() {
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
  }

  DailyMealPlan get currentDayPlan {
    return weeklyPlans.firstWhere((plan) => plan.day == selectedDay);
  }

  void _swapMeal(String category) {
    EasyLoading.showInfo('Swap $category - Coming soon!');
  }

  void _generateShoppingList() {
    EasyLoading.showSuccess('Shopping list generated for ${selectedDay}!');
  }

  @override
  Widget build(BuildContext context) {
    final currentPlan = currentDayPlan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Planner'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun',
                ]
                    .map(
                      (day) => GestureDetector(
                        onTap: () {
                          setState(() => selectedDay = day);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selectedDay == day
                                ? const Color(0xFF7CB342)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: selectedDay == day
                                  ? Colors.white
                                  : Colors.grey.shade600,
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
              currentPlan.meals
                  .where((m) => m.category == 'lunch')
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Dinner section
            _buildMealSection(
              'DINNER',
              '🍽️',
              currentPlan.meals
                  .where((m) => m.category == 'dinner')
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Daily total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Total: ${currentPlan.totalCalories} kcal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Generate shopping list button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _generateShoppingList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Generate Shopping List',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
        Text(
          '$title $emoji',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ...meals.map((meal) => _buildMealCard(meal)).toList(),
      ],
    );
  }

  Widget _buildMealCard(MealModel meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Meal icon placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF7CB342).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.restaurant,
                color: const Color(0xFF7CB342),
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Meal info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${meal.calories} kcal',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7CB342).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        meal.benefits,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7CB342),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Swap button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF7CB342).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: GestureDetector(
              onTap: () => _swapMeal(meal.category),
              child: const Text(
                'SWAP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7CB342),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
