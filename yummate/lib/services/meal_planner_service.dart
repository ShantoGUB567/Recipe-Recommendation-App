import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yummate/models/meal_plan_model.dart';

class MealPlannerService {
  late final GenerativeModel _model;

  MealPlannerService() {
    final apiKey = dotenv.env['GOOGLE_AI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GOOGLE_AI_API_KEY not found in .env file');
    }
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  Future<List<DailyMealPlan>> generateWeeklyMealPlan({
    Map<String, dynamic>? userProfile,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    int? targetCalories,
  }) async {
    try {
      debugPrint('🍽️ Generating weekly meal plan with Gemini AI...');

      final prompt = _buildMealPlanPrompt(
        userProfile: userProfile,
        dietaryPreferences: dietaryPreferences,
        allergies: allergies,
        targetCalories: targetCalories,
      );

      debugPrint('📝 Prompt created, sending to Gemini...');
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';

      debugPrint('✅ Received response from Gemini');
      debugPrint(
        'Response preview: ${text.substring(0, text.length > 200 ? 200 : text.length)}...',
      );

      return _parseMealPlan(text);
    } catch (e) {
      debugPrint('❌ Error generating meal plan: $e');
      throw Exception('Error generating meal plan: $e');
    }
  }

  String _buildMealPlanPrompt({
    Map<String, dynamic>? userProfile,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    int? targetCalories,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Generate a complete 7-day meal plan (Monday to Sunday) with the following specifications:',
    );
    buffer.writeln();

    // User profile considerations
    if (userProfile != null) {
      if (userProfile['age'] != null) {
        buffer.writeln('- Age: ${userProfile['age']}');
      }
      if (userProfile['gender'] != null) {
        buffer.writeln('- Gender: ${userProfile['gender']}');
      }
      if (userProfile['activityLevel'] != null) {
        buffer.writeln('- Activity Level: ${userProfile['activityLevel']}');
      }
      if (userProfile['primaryGoal'] != null) {
        buffer.writeln('- Goal: ${userProfile['primaryGoal']}');
      }
    }

    // Dietary preferences
    if (dietaryPreferences != null && dietaryPreferences.isNotEmpty) {
      buffer.writeln('- Dietary Preferences: ${dietaryPreferences.join(", ")}');
    }

    // Allergies
    if (allergies != null && allergies.isNotEmpty) {
      buffer.writeln('- AVOID these allergens: ${allergies.join(", ")}');
    }

    // Target calories
    final dailyCalories = targetCalories ?? 2000;
    buffer.writeln(
      '- Target Daily Calories: ~$dailyCalories kcal (distributed across breakfast, lunch, and dinner)',
    );
    buffer.writeln();

    buffer.writeln('''
For EACH DAY (Monday through Sunday), provide:

**DAY: [Day name]**

BREAKFAST:
Name: [Breakfast dish name]
Calories: [Number only, e.g., 350]
Benefits: [Key nutritional benefit in 3-4 words, e.g., "Protein & Fiber"]
Description: [Brief 1-sentence description]
Preparation Time: [e.g., 15 min or 30 min]
Servings: [Number like 2 or 4]
Ingredients:
- [ingredient with quantity]
- [ingredient with quantity]
- [ingredient with quantity]
Instructions:
1. [Cooking step]
2. [Cooking step]
3. [Cooking step]

LUNCH:
Name: [Lunch dish name]
Calories: [Number only, e.g., 520]
Benefits: [Key nutritional benefit in 3-4 words]
Description: [Brief 1-sentence description]
Preparation Time: [e.g., 25 min or 45 min]
Servings: [Number like 2 or 4]
Ingredients:
- [ingredient with quantity]
- [ingredient with quantity]
- [ingredient with quantity]
Instructions:
1. [Cooking step]
2. [Cooking step]
3. [Cooking step]

DINNER:
Name: [Dinner dish name]
Calories: [Number only, e.g., 480]
Benefits: [Key nutritional benefit in 3-4 words]
Description: [Brief 1-sentence description]
Preparation Time: [e.g., 35 min or 1 hr]
Servings: [Number like 2 or 4]
Ingredients:
- [ingredient with quantity]
- [ingredient with quantity]
- [ingredient with quantity]
Instructions:
1. [Cooking step]
2. [Cooking step]
3. [Cooking step]

---

Important:
- Each meal should be different and varied
- Balance nutrition across the week
- Consider the user's preferences and restrictions
- Keep benefits short (3-4 words max)
- Make meals realistic and easy to prepare
- Distribute calories appropriately (breakfast ~30%, lunch ~35%, dinner ~35%)
- Include 3-5 ingredients per meal with quantities
- Provide 3-5 clear cooking steps per meal
- Separate each day with "---"
''');

    return buffer.toString();
  }

  List<DailyMealPlan> _parseMealPlan(String text) {
    debugPrint('🔍 Parsing meal plan...');

    final weeklyPlans = <DailyMealPlan>[];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayAbbreviations = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    try {
      // Split by day sections
      final sections = text.split('---');

      for (int i = 0; i < sections.length && i < 7; i++) {
        final section = sections[i].trim();
        if (section.isEmpty) continue;

        debugPrint(
          'Processing section $i: ${section.substring(0, section.length > 100 ? 100 : section.length)}...',
        );

        // Extract day name
        String dayName = dayAbbreviations[i];
        final dayMatch = RegExp(
          r'\*\*DAY:\s*(\w+)\*\*',
          caseSensitive: false,
        ).firstMatch(section);
        if (dayMatch != null) {
          final fullDay = dayMatch.group(1)!;
          final dayIndex = days.indexWhere(
            (d) => d.toLowerCase().startsWith(fullDay.toLowerCase()),
          );
          if (dayIndex != -1) {
            dayName = dayAbbreviations[dayIndex];
          }
        }

        // Extract meals
        final meals = <MealModel>[];

        // Parse breakfast
        final breakfast = _extractMeal(
          section,
          'BREAKFAST',
          'breakfast',
          i * 3 + 1,
        );
        if (breakfast != null) meals.add(breakfast);

        // Parse lunch
        final lunch = _extractMeal(section, 'LUNCH', 'lunch', i * 3 + 2);
        if (lunch != null) meals.add(lunch);

        // Parse dinner
        final dinner = _extractMeal(section, 'DINNER', 'dinner', i * 3 + 3);
        if (dinner != null) meals.add(dinner);

        if (meals.isNotEmpty) {
          weeklyPlans.add(DailyMealPlan(day: dayName, meals: meals));
          debugPrint('✅ Added $dayName with ${meals.length} meals');
        }
      }

      debugPrint('✅ Successfully parsed ${weeklyPlans.length} days');
      return weeklyPlans;
    } catch (e) {
      debugPrint('❌ Error parsing meal plan: $e');
      // Return default meal plan on error
      return _getDefaultMealPlan();
    }
  }

  MealModel? _extractMeal(
    String section,
    String mealType,
    String category,
    int id,
  ) {
    try {
      // Find the meal section - extract everything from MEALTYPE: to next meal type or end
      final mealRegex = RegExp(
        '$mealType:[\\s\\S]*?(?=(?:BREAKFAST:|LUNCH:|DINNER:|---|\\Z))',
        caseSensitive: false,
      );

      final match = mealRegex.firstMatch(section);
      if (match != null) {
        final mealText = match.group(0)!;

        // Extract all meal details
        final nameMatch = RegExp(
          r'Name:\\s*([^\\n]+)',
          caseSensitive: false,
        ).firstMatch(mealText);
        final caloriesMatch = RegExp(
          r'Calories:\\s*(\\d+)',
          caseSensitive: false,
        ).firstMatch(mealText);
        final benefitsMatch = RegExp(
          r'Benefits:\\s*([^\\n]+)',
          caseSensitive: false,
        ).firstMatch(mealText);
        final descMatch = RegExp(
          r'Description:\\s*([^\\n]+)',
          caseSensitive: false,
        ).firstMatch(mealText);
        final prepTimeMatch = RegExp(
          r'Preparation Time:\\s*([^\\n]+)',
          caseSensitive: false,
        ).firstMatch(mealText);
        final servingsMatch = RegExp(
          r'Servings:\\s*([^\\n]+)',
          caseSensitive: false,
        ).firstMatch(mealText);

        // Extract ingredients
        final ingredients = <String>[];
        final ingredientsSection = RegExp(
          r'Ingredients:([\\s\\S]*?)(?=Instructions:|$)',
          caseSensitive: false,
        ).firstMatch(mealText);
        if (ingredientsSection != null) {
          final ingredientText = ingredientsSection.group(1)!;
          final ingredientMatches = RegExp(
            r'-\\s*([^\\n]+)',
          ).allMatches(ingredientText);
          for (final ingMatch in ingredientMatches) {
            final ingredient = ingMatch.group(1)!.trim();
            if (ingredient.isNotEmpty &&
                !ingredient.toLowerCase().contains('ingredient')) {
              ingredients.add(ingredient);
            }
          }
        }

        // Extract instructions
        final instructions = <String>[];
        final instructionsSection = RegExp(
          r'Instructions:([\\s\\S]*?)$',
          caseSensitive: false,
        ).firstMatch(mealText);
        if (instructionsSection != null) {
          final instructionText = instructionsSection.group(1)!;
          final instructionMatches = RegExp(
            r'\\d+\\.\\s*([^\\n]+)',
          ).allMatches(instructionText);
          for (final instMatch in instructionMatches) {
            final instruction = instMatch.group(1)!.trim();
            if (instruction.isNotEmpty &&
                !instruction.toLowerCase().contains('cooking step')) {
              instructions.add(instruction);
            }
          }
        }

        final name = nameMatch?.group(1)?.trim() ?? '';
        final calories =
            int.tryParse(caloriesMatch?.group(1)?.trim() ?? '0') ?? 0;
        final benefits = benefitsMatch?.group(1)?.trim() ?? 'Nutritious';

        if (name.isNotEmpty && calories > 0) {
          debugPrint(
            '✅ Parsed $mealType: $name with ${ingredients.length} ingredients, ${instructions.length} steps',
          );
          return MealModel(
            id: id.toString(),
            name: name,
            calories: calories,
            category: category,
            benefits: benefits,
            description: descMatch?.group(1)?.trim() ?? '',
            preparationTime: prepTimeMatch?.group(1)?.trim() ?? '30 min',
            servings: servingsMatch?.group(1)?.trim() ?? '4',
            ingredients: ingredients,
            instructions: instructions,
          );
        }
      }
    } catch (e) {
      debugPrint('Error extracting $mealType: $e');
    }
    return null;
  }

  List<DailyMealPlan> _getDefaultMealPlan() {
    debugPrint('⚠️ Using default meal plan');
    return [
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
      // Add other days as fallback...
    ];
  }
}
