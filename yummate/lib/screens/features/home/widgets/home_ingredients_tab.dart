import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/generate_recipe/screen/generate_recipe_screen.dart';
import 'package:yummate/services/gemini_service.dart';
import 'package:yummate/models/recipe_model.dart';

class HomeIngredientsTab extends StatefulWidget {
  final TextEditingController ingredientController;
  final List<String> initialIngredients;
  final List<String> cuisineList;
  final GeminiService geminiService;
  final Function(List<String>) onIngredientsChanged;
  final Function(File?) onImageChanged;

  const HomeIngredientsTab({
    super.key,
    required this.ingredientController,
    required this.initialIngredients,
    required this.cuisineList,
    required this.geminiService,
    required this.onIngredientsChanged,
    required this.onImageChanged,
  });

  @override
  State<HomeIngredientsTab> createState() => _HomeIngredientsTabState();
}

class _HomeIngredientsTabState extends State<HomeIngredientsTab> {
  late List<String> ingredients;
  File? pickedImage;
  String? selectedCuisine;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    ingredients = List.from(widget.initialIngredients);
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Add Ingredient Photo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pickIngredientImage(ImageSource.camera);
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.deepOrange.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 32,
                              color: Colors.deepOrange,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Camera',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pickIngredientImage(ImageSource.gallery);
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.image, size: 32, color: Colors.green),
                            const SizedBox(height: 12),
                            const Text(
                              'Gallery',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickIngredientImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });
      widget.onImageChanged(pickedImage);

      if (!mounted) return;
      EasyLoading.show(status: 'Detecting ingredients from image...');

      try {
        debugPrint('Starting ingredient detection from image...');
        final detectedIngredients = await widget.geminiService
            .identifyIngredientsFromImage(File(image.path));

        debugPrint(
          'Detection complete. Found ${detectedIngredients.length} ingredients',
        );

        if (detectedIngredients.isNotEmpty && mounted) {
          setState(() {
            for (final ingredient in detectedIngredients) {
              if (!ingredients.contains(ingredient)) {
                ingredients.add(ingredient);
              }
            }
            widget.onIngredientsChanged(ingredients);
          });

          EasyLoading.showSuccess(
            'Found ${detectedIngredients.length} ingredient(s)!',
          );
        } else if (mounted) {
          EasyLoading.showInfo('No ingredients detected. Try a clearer image.');
        }
      } catch (e) {
        debugPrint('Error detecting ingredients: $e');
        if (mounted) {
          EasyLoading.showError('Error: ${e.toString()}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.kitchen,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Your Ingredients",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Add what you have, we'll create magic!",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // Cuisine Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedCuisine,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.public,
                        color: Colors.deepOrange,
                        size: 20,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    hint: const Text("Select Cuisine (Optional)"),
                    isExpanded: true,
                    items: widget.cuisineList.map((cuisine) {
                      return DropdownMenuItem(
                        value: cuisine,
                        child: Text(cuisine),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedCuisine = value),
                  ),
                ),

                const SizedBox(height: 20),

                // Image Picker
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: pickedImage != null
                            ? Colors.deepOrange
                            : Colors.grey.shade300,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: pickedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Upload Ingredient Photo",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "(Optional)",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  pickedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => pickedImage = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Ingredient Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.ingredientController,
                        decoration: InputDecoration(
                          hintText: "Add ingredient...",
                          prefixIcon: const Icon(
                            Icons.add,
                            color: Colors.deepOrange,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.deepOrange,
                              width: 2,
                            ),
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            setState(() {
                              ingredients.add(value.trim());
                              widget.ingredientController.clear();
                              widget.onIngredientsChanged(ingredients);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (widget.ingredientController.text
                              .trim()
                              .isNotEmpty) {
                            setState(() {
                              ingredients.add(
                                widget.ingredientController.text.trim(),
                              );
                              widget.ingredientController.clear();
                              widget.onIngredientsChanged(ingredients);
                            });
                          }
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                // Selected Ingredients
                if (ingredients.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Ingredients (${ingredients.length})",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ingredients.map((item) {
                      return Chip(
                        label: Text(item),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() => ingredients.remove(item));
                          widget.onIngredientsChanged(ingredients);
                        },
                        backgroundColor: Colors.green.shade50,
                        side: BorderSide(color: Colors.green.shade200),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 24),

                // Generate Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isGenerating
                        ? null
                        : () async {
                            if (ingredients.isEmpty && pickedImage == null) {
                              EasyLoading.showInfo(
                                'Add at least 1 ingredient!',
                              );
                              return;
                            }

                            setState(() => _isGenerating = true);

                            try {
                              final response = await widget.geminiService
                                  .generateRecipe(
                                    ingredients: ingredients,
                                    cuisine: selectedCuisine,
                                    imageFile: pickedImage,
                                  );

                              final recipes = RecipeModel.parseMultipleRecipes(
                                response,
                              );

                              Get.to(
                                () => GenerateRecipeScreen(
                                  recipes: recipes,
                                  rawResponse: response,
                                  query:
                                      'Ingredients: ${ingredients.join(", ")}',
                                  type: 'generate',
                                ),
                              );
                            } catch (e) {
                              EasyLoading.showError('Error: $e');
                            } finally {
                              setState(() => _isGenerating = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isGenerating
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Generating...",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome),
                              SizedBox(width: 8),
                              Text(
                                "Generate Recipe",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
