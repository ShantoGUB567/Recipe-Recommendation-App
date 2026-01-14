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

    // Using gemini-2.5-flash for both text and vision
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    _visionModel = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
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

**Preparation Time:** [Total approximate time including all prep, marination, and cooking - format like: 1 Hr 10 Min or 30 Min or 45 Min]

**Servings:** [Number of servings like: 4 or 6]

**Calories:** [Total calories as number only, like: 780]

**Description:** [Brief description of the dish]

**Ingredients:**
- [quantity] [unit] [ingredient name] (e.g., "4 large baking potatoes" or "3 tablespoons olive oil, divided")
- Include exact measurements (cups, tablespoons, teaspoons, ounces, grams, etc.)
- Be specific with quantities and preparations (e.g., "2 cups cheese, grated" or "Salt and ground black pepper")

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

**Preparation Time:** [Total approximate time including all prep, marination, and cooking - format like: 1 Hr 10 Min or 30 Min or 45 Min]

**Servings:** [Number of servings like: 4 or 6]

**Calories:** [Total calories as number only, like: 780]

**Description:** [Brief description of the dish]

**Ingredients:**
- [quantity] [unit] [ingredient name] (e.g., "4 large baking potatoes" or "3 tablespoons olive oil, divided")
- Include exact measurements (cups, tablespoons, teaspoons, ounces, grams, etc.)
- Be specific with quantities and preparations (e.g., "2 cups cheese, grated" or "Salt and ground black pepper")

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
      print('Reading image file: ${imageFile.path}');
      final imageBytes = await imageFile.readAsBytes();
      print('Image bytes read: ${imageBytes.length} bytes');

      // Determine image MIME type from file extension
      String mimeType = 'image/jpeg';
      final extension = imageFile.path.toLowerCase().split('.').last;
      if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (extension == 'webp') {
        mimeType = 'image/webp';
      }
      print('Using MIME type: $mimeType');

      final imagePart = DataPart(mimeType, imageBytes);

      final prompt =
          '''Look at this image and list all the food ingredients you can see.
Provide ONLY the ingredient names, one per line.
Do not add numbers, bullets, or descriptions.
Just simple ingredient names like: tomato, onion, chicken, rice''';

      print('Sending request to Gemini vision model...');
      final response = await _visionModel.generateContent([
        Content.multi([TextPart(prompt), imagePart]),
      ]);

      print('Received response from Gemini');
      final text = response.text ?? '';
      print('Response text: $text');

      if (text.isEmpty) {
        throw Exception('No response from Gemini vision model');
      }

      final ingredients = text
          .split('\n')
          .map((line) => line.trim())
          .map(
            (line) => line.replaceAll(RegExp(r'^[\d+\.\-\*\)\s]+'), ''),
          ) // Remove bullets and numbers
          .where((line) => line.isNotEmpty && line.length > 1)
          .toList();

      print('Parsed ingredients: $ingredients');
      return ingredients;
    } catch (e) {
      print('Error in identifyIngredientsFromImage: $e');
      throw Exception('Error identifying ingredients: $e');
    }
  }
}
