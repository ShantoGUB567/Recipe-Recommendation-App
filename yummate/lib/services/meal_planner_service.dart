import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:yummate/models/meal_plan_model.dart';
import 'package:intl/intl.dart'; // তারিখ ফরম্যাট করার জন্য (pubspec.yaml এ থাকতে হবে)

class MealPlannerService {
  late final GenerativeModel _model;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MealPlannerService() {
    final apiKey = dotenv.env['GOOGLE_AI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GOOGLE_AI_API_KEY not found in .env file');
    }
    // gemini-2.5-flash ব্যবহার করা নিরাপদ, যেহেতু অন্য ফাইলে কাজ করছে
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', 
      apiKey: apiKey,
    );
  }

  // সপ্তাহের দিনগুলোর নাম পাওয়ার হেল্পার ফাংশন
  String _getDayName(DateTime date) {
    return DateFormat('EEE').format(date); // Mon, Tue, etc.
  }
  // Firebase এ মিল প্ল্যান সংরক্ষণ করা
  Future<void> saveMealPlanToFirebase(List<DailyMealPlan> mealPlans) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('❌ User not logged in');
        return;
      }

      final now = DateTime.now();
      final planId = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      final dbRef = _database.ref()
          .child('weekly_meal_plans')
          .child(user.uid)
          .child(planId);

      // মিল প্ল্যানকে JSON এ কনভার্ট করা
      final planData = {
        'generatedDate': now.toIso8601String(),
        'startDate': mealPlans.isNotEmpty 
            ? _extractDateFromDay(mealPlans.first.day) 
            : now.toIso8601String(),
        'endDate': mealPlans.isNotEmpty 
            ? _extractDateFromDay(mealPlans.last.day) 
            : now.add(Duration(days: 6)).toIso8601String(),
        'meals': mealPlans.map((dailyPlan) {
          return {
            'day': dailyPlan.day,
            'meals': dailyPlan.meals.map((meal) {
              return {
                'id': meal.id,
                'name': meal.name,
                'calories': meal.calories,
                'category': meal.category,
                'benefits': meal.benefits,
                'description': meal.description,
                'preparationTime': meal.preparationTime,
                'servings': meal.servings,
                'ingredients': meal.ingredients,
                'instructions': meal.instructions,
              };
            }).toList(),
          };
        }).toList(),
      };

      await dbRef.set(planData);
      debugPrint('✅ Meal plan saved to Firebase');
    } catch (e) {
      debugPrint('❌ Error saving meal plan to Firebase: $e');
    }
  }

  // Firebase থেকে মিল প্ল্যান লোড করা
  Future<List<DailyMealPlan>?> loadMealPlanFromFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('❌ User not logged in');
        return null;
      }

      final now = DateTime.now();
      final planId = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      final dbRef = _database.ref()
          .child('weekly_meal_plans')
          .child(user.uid)
          .child(planId);

      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        
        // আজকের তারিখ সেই plan এর range এর মধ্যে আছে কিনা চেক করা
        final startDate = DateTime.parse(data['startDate']);
        final endDate = DateTime.parse(data['endDate']);
        
        if (now.isAfter(startDate) && now.isBefore(endDate.add(Duration(days: 1)))) {
          return _convertFirebaseDataToMealPlans(data);
        } else {
          debugPrint('⚠️ Meal plan is expired (outside date range)');
          return null;
        }
      } else {
        debugPrint('⚠️ No meal plan found in Firebase for today');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error loading meal plan from Firebase: $e');
      return null;
    }
  }

  // Firebase ডেটা কে MealPlan অবজেক্টে কনভার্ট করা
  List<DailyMealPlan> _convertFirebaseDataToMealPlans(Map<dynamic, dynamic> data) {
    final List<dynamic> mealsList = data['meals'] ?? [];
    
    return mealsList.map((dayData) {
      final List<dynamic> mealsData = dayData['meals'] ?? [];
      
      final meals = mealsData.map((m) => MealModel(
        id: m['id'] ?? '',
        name: m['name'] ?? 'Meal',
        calories: m['calories'] ?? 0,
        category: m['category'] ?? 'lunch',
        benefits: m['benefits'] ?? '',
        description: m['description'] ?? '',
        preparationTime: m['preparationTime'] ?? '20 min',
        servings: m['servings']?.toString() ?? '1',
        ingredients: List<String>.from(m['ingredients'] ?? []),
        instructions: List<String>.from(m['instructions'] ?? []),
      )).toList();

      return DailyMealPlan(day: dayData['day'], meals: meals);
    }).toList();
  }

  // তারিখ স্ট্রিং থেকে Date এক্সট্র্যাক্ট করা
  String _extractDateFromDay(String dayString) {
    // Format: "Mon (2026-01-28)"
    final regex = RegExp(r'\((\d{4}-\d{2}-\d{2})\)');
    final match = regex.firstMatch(dayString);
    if (match != null) {
      return '${match.group(1)}T00:00:00.000Z';
    }
    return DateTime.now().toIso8601String();
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

      debugPrint('✅ Received response from Gemini:');
      debugPrint('================ FULL JSON START ================');
      debugPrint(text, wrapWidth: 1024); 
      debugPrint('================ FULL JSON END ==================');

      if (text.isEmpty) throw Exception('Empty response from AI');

      final mealPlans = _parseMealPlan(text);
      
      // Firebase এ সেভ করা
      await saveMealPlanToFirebase(mealPlans);
      
      return mealPlans;
    } catch (e) {
      debugPrint('❌ Error generating meal plan: $e');
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
    final now = DateTime.now();
    
    // আজ থেকে আগামী ৭ দিনের সিকোয়েন্স তৈরি
    final List<String> dateSequence = List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      return "${_getDayName(date)} (${DateFormat('yyyy-MM-dd').format(date)})";
    });

    return '''
Act as a nutritionist. Generate a 7-day healthy meal plan starting from TODAY.
Today is ${_getDayName(now)}, ${DateFormat('dd MMM yyyy').format(now)}.

User Profile:
- Goal: ${userProfile?['primaryGoal'] ?? 'Healthy Living'}
- Allergies: ${allergies?.join(", ") ?? "None"}
- Target: $dailyCalories kcal/day.

Instructions (KEEP ALL EXISTING RULES):
1. Return ONLY a JSON array of 7 objects.
2. The "day" field MUST follow this sequence and format: ${dateSequence.join(", ")}.
3. Each object MUST have:
  "day": "DayName (YYYY-MM-DD)",
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
    final now = DateTime.now();
    return [
      DailyMealPlan(
        day: "${_getDayName(now)} (${DateFormat('yyyy-MM-dd').format(now)})",
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