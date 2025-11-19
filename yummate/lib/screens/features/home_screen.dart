import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yummate/core/widgets/app_drawer.dart';
import 'package:yummate/screens/features/generate_recipe/recipe_result_screen.dart';
import 'package:yummate/screens/generate_recipe_screen.dart';
import 'package:yummate/screens/features/saved_recipes_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController ingredientController = TextEditingController();
  final List<String> ingredients = [];
  File? pickedImage;

  String? selectedCuisine;

  final List<String> cuisineList = [
    "Bangladeshi",
    "Indian",
    "Chinese",
    "Italian",
    "Thai",
    "Mexican",
    "American",
  ];

  Future pickIngredientImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Yummate",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 2,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Greeting card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.orange.shade100,
                    child: Text(widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'Y', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFEF6C00))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, ${widget.userName} 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('What do you want to cook today?', style: TextStyle(color: Colors.grey.shade800)),
                      ],
                    ),
                  ),
                  // Quick actions
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => Get.to(() => SavedRecipesScreen()),
                        icon: const Icon(Icons.bookmark, color: Colors.deepOrange),
                      ),
                      const Text('Saved', style: TextStyle(fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 18),

            /// Cuisine Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: selectedCuisine,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                hint: const Text("Select Cuisine Type"),
                items: cuisineList.map((cuisine) {
                  return DropdownMenuItem(
                    value: cuisine,
                    child: Text(cuisine),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCuisine = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 25),

            // Combined image upload + manual ingredient input in a single row
            Text(
              "Add Ingredients",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image upload box (thumbnail) - height matches input field
                GestureDetector(
                  onTap: pickIngredientImage,
                  child: Container(
                    height: 56,
                    width: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: pickedImage == null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_rounded,
                                  size: 22, color: Colors.grey.shade600),
                              const SizedBox(width: 6),
                              // Text(
                              //   "Photo",
                              //   style: TextStyle(
                              //       color: Colors.grey.shade700, fontSize: 12),
                              // ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              pickedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Ingredient input + add button
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: ingredientController,
                              decoration: const InputDecoration(
                                hintText: "Enter ingredient (e.g. chicken, tomato)",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            onPressed: () {
                              if (ingredientController.text.trim().isNotEmpty) {
                                setState(() {
                                  ingredients.add(ingredientController.text.trim());
                                  ingredientController.clear();
                                });
                              }
                            },
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Show Added Ingredients
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ingredients.map((item) {
                return Chip(
                  label: Text(item),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      ingredients.remove(item);
                    });
                  },
                  backgroundColor: Colors.orange.shade100,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 35),

            /// Generate Recipe Button
            Center(
              child: GestureDetector(
                onTap: () {
                  if (ingredients.isEmpty && pickedImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please add at least 1 ingredient!"),
                      ),
                    );
                    return;
                  }

                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => RecipeScreen(
                  //       ingredients: ingredients,
                  //       image: pickedImage,
                  //       cuisine: selectedCuisine,
                  //     ),
                  //   ),
                  // );

                  Get.to(() => GenerateRecipeScreen());

                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.shade200,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Generate Recipe",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // ⭐ ADD DRAWER HERE
      drawer: AppDrawer(userName: widget.userName),

    );
  }
}

/// Dummy next screen placeholder
class RecipeScreen extends StatelessWidget {
  final List<String> ingredients;
  final File? image;
  final String? cuisine;

  const RecipeScreen({
    super.key,
    required this.ingredients,
    required this.image,
    required this.cuisine,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generated Recipe"),
      ),
    );
  }
}
