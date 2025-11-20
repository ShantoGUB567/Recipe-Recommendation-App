import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class GeminiService {
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;

  GeminiService() {
    final apiKey = dotenv.env['GOOGLE_AI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GOOGLE_AI_API_KEY not found in .env file');
    }

    // Text-only model - Using Gemini 2.0 Flash
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    // Vision model for image analysis - Using Gemini 2.0 Flash
    _visionModel = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: apiKey,
    );
  }

  Future<String> generateRecipe({
    required List<String> ingredients,
    String? cuisine,
    File? imageFile,
  }) async {
    try {
      String prompt = _buildPrompt(ingredients, cuisine);

      if (imageFile != null) {
        // Use vision model if image is provided
        final imageBytes = await imageFile.readAsBytes();
        final imagePart = DataPart('image/jpeg', imageBytes);

        final response = await _visionModel.generateContent([
          Content.multi([
            TextPart(
              '$prompt\n\nAlso consider the ingredients visible in this image.',
            ),
            imagePart,
          ]),
        ]);

        return response.text ?? 'Failed to generate recipe';
      } else {
        // Text-only generation
        final response = await _model.generateContent([Content.text(prompt)]);
        return response.text ?? 'Failed to generate recipe';
      }
    } catch (e) {
      throw Exception('Error generating recipe: $e');
    }
  }

  String _buildPrompt(List<String> ingredients, String? cuisine) {
    final ingredientList = ingredients.join(', ');
    final cuisineText = cuisine != null ? ' $cuisine' : '';

    return '''
Generate 3 different${cuisineText} recipes using these ingredients: $ingredientList.

For EACH recipe, provide the response in the following format:

**Recipe Name:** [Creative recipe name]

**Preparation Time:** [Time in minutes]

**Calories:** [Approximate calories]

**Description:** [Brief description of the dish]

**Ingredients:**
- [List each ingredient with measurements]

**Instructions:**
1. [Step-by-step cooking instructions]

---

Make each recipe unique, delicious and easy to follow! Separate each recipe with "---".
''';
  }

  Future<String> searchRecipe({
    required String recipeName,
    String? cuisine,
  }) async {
    try {
      final cuisineText = cuisine != null ? ' $cuisine' : '';

      final prompt =
          '''
Generate 3 different variations of${cuisineText} $recipeName recipes.

For EACH recipe variation, provide the response in the following format:

**Recipe Name:** [Recipe name with variation]

**Preparation Time:** [Time in minutes]

**Calories:** [Approximate calories]

**Description:** [Brief description of the dish]

**Ingredients:**
- [List each ingredient with measurements]

**Instructions:**
1. [Step-by-step cooking instructions]

---

Make each variation unique, authentic, delicious and easy to follow! Separate each recipe with "---".
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Failed to generate recipe';
    } catch (e) {
      throw Exception('Error searching recipe: $e');
    }
  }

  Future<List<String>> identifyIngredientsFromImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final imagePart = DataPart('image/jpeg', imageBytes);

      final prompt = '''
Analyze this image and identify all food ingredients visible.
List only the ingredient names, one per line, without numbers or extra text.
Only list recognizable food items or ingredients.
''';

      final response = await _visionModel.generateContent([
        Content.multi([TextPart(prompt), imagePart]),
      ]);

      final text = response.text ?? '';
      return text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.trim())
          .toList();
    } catch (e) {
      throw Exception('Error identifying ingredients: $e');
    }
  }
}
