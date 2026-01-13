import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yummate/core/widgets/app_drawer.dart';
import 'package:yummate/screens/generate_recipe_screen.dart';
import 'package:yummate/screens/features/saved_recipes_screen.dart';
import 'package:yummate/services/gemini_service.dart';
import 'package:yummate/models/recipe_model.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController ingredientController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final List<String> ingredients = [];
  File? pickedImage;
  final GeminiService _geminiService = GeminiService();
  bool _isGenerating = false;
  bool _isSearching = false;
  late TabController _tabController;

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    ingredientController.dispose();
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
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
                        pickIngredientImage(ImageSource.camera);
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
                              size: 48,
                              color: Colors.deepOrange,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Camera',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
                        pickIngredientImage(ImageSource.gallery);
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
                            Icon(
                              Icons.photo_library,
                              size: 48,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Gallery',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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

  Future pickIngredientImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });

      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
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
                'Detecting ingredients from image...',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: Colors.deepOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // Detect ingredients from image
      try {
        print('Starting ingredient detection from image...');
        final detectedIngredients = await _geminiService
            .identifyIngredientsFromImage(File(image.path));

        print(
          'Detection complete. Found ${detectedIngredients.length} ingredients',
        );

        if (detectedIngredients.isNotEmpty && mounted) {
          setState(() {
            // Add detected ingredients that aren't already in the list
            for (final ingredient in detectedIngredients) {
              if (!ingredients.contains(ingredient)) {
                ingredients.add(ingredient);
              }
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Found ${detectedIngredients.length} ingredient(s)!',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.info, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No ingredients detected. Try a clearer image.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.blue.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        print('Error detecting ingredients: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Error: ${e.toString()}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _searchForRecipe(String recipeName) async {
    if (recipeName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Please enter a recipe name to search!",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      final response = await _geminiService.searchRecipe(
        recipeName: recipeName.trim(),
        cuisine: selectedCuisine,
      );

      final recipes = RecipeModel.parseMultipleRecipes(response);

      Get.to(
        () => GenerateRecipeScreen(recipes: recipes, rawResponse: response),
      );

      searchController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error: ${e.toString()}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange, Colors.orange.shade600],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Yummate",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => SavedRecipesScreen()),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.bookmark, color: Colors.deepOrange, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(userName: widget.userName),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Message
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                          height: 1.3,
                        ),
                        children: [
                          const TextSpan(text: "Hello "),
                          TextSpan(
                            text: widget.userName,
                            style: const TextStyle(color: Colors.deepOrange),
                          ),
                          const TextSpan(text: "! 👋\n"),
                          TextSpan(
                            text: "What's cooking today?",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tab Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Tab Bar
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey.shade100, Colors.grey.shade200],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.deepOrange,
                      unselectedLabelColor: Colors.grey.shade600,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      tabs: [
                        Tab(
                          height: 48,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_rounded, size: 20),
                              const SizedBox(width: 8),
                              const Text("Search"),
                            ],
                          ),
                        ),
                        Tab(
                          height: 48,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant, size: 20),
                              const SizedBox(width: 8),
                              const Text("Ingredients"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tab Views
                  SizedBox(
                    height: size.height * 0.65,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Search Tab
                        _buildSearchTab(),

                        // Ingredients Tab
                        _buildIngredientsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                        color: Colors.deepOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.deepOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Find Your Recipe",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Search for any dish you want to cook",
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
                    value: selectedCuisine,
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
                    items: cuisineList.map((cuisine) {
                      return DropdownMenuItem(
                        value: cuisine,
                        child: Text(cuisine),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedCuisine = value),
                  ),
                ),

                const SizedBox(height: 16),

                // Search Input
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Type recipe name... (e.g., Pizza, Pasta)",
                    prefixIcon: const Icon(
                      Icons.restaurant_menu,
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
                      _searchForRecipe(value);
                    }
                  },
                ),

                const SizedBox(height: 20),

                // Search Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSearching
                        ? null
                        : () {
                            if (searchController.text.trim().isNotEmpty) {
                              _searchForRecipe(searchController.text);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSearching
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
                                "Searching...",
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
                              Icon(Icons.search),
                              SizedBox(width: 8),
                              Text(
                                "Search Recipe",
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

          const SizedBox(height: 20),

          // Popular Searches
          Text(
            "Popular Searches",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPopularChip("Biryani", Icons.rice_bowl),
              _buildPopularChip("Pizza", Icons.local_pizza),
              _buildPopularChip("Pasta", Icons.ramen_dining),
              _buildPopularChip("Curry", Icons.soup_kitchen),
              _buildPopularChip("Burger", Icons.lunch_dining),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularChip(String label, IconData icon) {
    return InkWell(
      onTap: () {
        searchController.text = label;
        _searchForRecipe(label);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.deepOrange),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ingredients Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                        color: Colors.green.withOpacity(0.1),
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
                    value: selectedCuisine,
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
                    items: cuisineList.map((cuisine) {
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
                        controller: ingredientController,
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
                              ingredientController.clear();
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
                          if (ingredientController.text.trim().isNotEmpty) {
                            setState(() {
                              ingredients.add(ingredientController.text.trim());
                              ingredientController.clear();
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
                        onDeleted: () =>
                            setState(() => ingredients.remove(item)),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "Add at least 1 ingredient!",
                                  ),
                                  backgroundColor: Colors.orange.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }

                            setState(() => _isGenerating = true);

                            try {
                              final response = await _geminiService
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
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red.shade600,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
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
    return Scaffold(appBar: AppBar(title: const Text("Generated Recipe")));
  }
}
