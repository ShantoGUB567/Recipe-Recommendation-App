import 'dart:convert';
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
    
    // মডেলের নাম 'gemini-2.5-flash' ই রাখা হয়েছে যেহেতু এটি অন্য ফাইলে কাজ করছে
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', 
      apiKey: apiKey,
    );
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

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';

      // --- এখান থেকে ডিবাগিং কোড শুরু ---
      debugPrint('✅ Received response from Gemini:');
      debugPrint('================ FULL JSON START ================');
      
      // wrapWidth ব্যবহার করলে কনসোল লিমিট থাকলেও ডাটা কাটবে না
      debugPrint(text, wrapWidth: 1024); 
      
      debugPrint('================ FULL JSON END ==================');
      // --- ডিবাগিং কোড শেষ ---

      if (text.isEmpty) {
        throw Exception('Empty response from AI');
      }

      debugPrint('✅ Received response from Gemini');
      return _parseMealPlan(text);
    } catch (e) {
      debugPrint('❌ Error generating meal plan: $e');
      // এরর হলে অ্যাপ ক্রাশ না করে ডিফল্ট প্ল্যান রিটার্ন করবে
      return _getDefaultMealPlan();
    }
  }

  String _buildMealPlanPrompt({
    Map<String, dynamic>? userProfile,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    int? targetCalories,
  }) {
    final dailyCalories = targetCalories ?? 2000;
    
    // প্রম্পটটিকে ছোট এবং পরিষ্কার করা হয়েছে যাতে AI এরর না দেয়
    return '''
Act as a nutritionist. Generate a 7-day healthy meal plan in strict JSON format.

User Profile:
- Goal: ${userProfile?['primaryGoal'] ?? 'Healthy Living'}
- Allergies: ${allergies?.join(", ") ?? "None"}
- Target: $dailyCalories kcal/day.

Instructions:
1. Return ONLY a JSON array of 7 objects.
2. Days: "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun".
3. Each object MUST have:
  "day": "DayName",
  "meals": [
    {
      "category": "breakfast/lunch/dinner",
      "name": "Meal Name",
      "calories": 500,
      "benefits": "Short benefit",
      "description": "Short description",
      "preparationTime": "20 min",
      "servings": "2",
      "ingredients": ["item 1", "item 2"],
      "instructions": ["step 1", "step 2"]
    }
  ]

Strictly avoid intro/outro text or markdown.
''';
  }

  List<DailyMealPlan> _parseMealPlan(String text) {
    debugPrint('🔍 Parsing meal plan JSON...');
    try {
      // JSON ক্লিন করা (Markdown রিমুভ করা)
      final cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> decodedList = jsonDecode(cleanJson);
      
      return decodedList.map((dayData) {
        final List<dynamic> mealList = dayData['meals'];
        
        final meals = mealList.map((m) => MealModel(
          id: DateTime.now().microsecondsSinceEpoch.toString() + (m['name'] ?? 'meal'),
          name: m['name'] ?? 'Healthy Meal',
          calories: m['calories'] ?? 0,
          category: m['category'] ?? 'lunch',
          benefits: m['benefits'] ?? 'Nutritious',
          description: m['description'] ?? '',
          preparationTime: m['preparationTime'] ?? '20 min',
          servings: m['servings'].toString(),
          ingredients: List<String>.from(m['ingredients'] ?? []),
          instructions: List<String>.from(m['instructions'] ?? []),
        )).toList();

        return DailyMealPlan(day: dayData['day'], meals: meals);
      }).toList();
    } catch (e) {
      debugPrint('❌ JSON Parsing Error: $e');
      return _getDefaultMealPlan();
    }
  }

  List<DailyMealPlan> _getDefaultMealPlan() {
    debugPrint('⚠️ Falling back to default meal plan');
    return [
      DailyMealPlan(
        day: 'Mon',
        meals: [
          MealModel(
            id: 'fall_1',
            name: 'Oatmeal with Fruits',
            calories: 350,
            category: 'breakfast',
            benefits: 'Fiber & Energy',
            description: 'Healthy start to the day.',
            preparationTime: '10 min',
            servings: '1',
            ingredients: ['Oats', 'Milk', 'Banana'],
            instructions: ['Boil milk', 'Add oats', 'Top with banana'],
          ),
        ],
      ),
    ];
  }
}