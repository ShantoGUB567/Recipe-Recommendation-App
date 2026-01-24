import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/generate_recipe_screen.dart';
import 'package:yummate/services/gemini_service.dart';
import 'package:yummate/models/recipe_model.dart';

class HomeSearchTab extends StatefulWidget {
  final TextEditingController searchController;
  final List<String> cuisineList;
  final GeminiService geminiService;
  final Function(String) onSearchSuccess;

  const HomeSearchTab({
    super.key,
    required this.searchController,
    required this.cuisineList,
    required this.geminiService,
    required this.onSearchSuccess,
  });

  @override
  State<HomeSearchTab> createState() => _HomeSearchTabState();
}

class _HomeSearchTabState extends State<HomeSearchTab> {
  String? selectedCuisine;
  bool _isSearching = false;

  Future<void> _searchForRecipe(String recipeName) async {
    if (recipeName.trim().isEmpty) {
      EasyLoading.showInfo('Please enter a recipe name to search!');
      return;
    }

    setState(() => _isSearching = true);

    try {
      final response = await widget.geminiService.searchRecipe(
        recipeName: recipeName.trim(),
        cuisine: selectedCuisine,
      );

      final recipes = RecipeModel.parseMultipleRecipes(response);

      Get.to(
        () => GenerateRecipeScreen(
          recipes: recipes,
          rawResponse: response,
          query: 'Search: ${recipeName.trim()}',
          type: 'search',
        ),
      );

      widget.searchController.clear();
      widget.onSearchSuccess(recipeName);
    } catch (e) {
      EasyLoading.showError('Error: ${e.toString()}');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        color: Colors.deepOrange.withValues(alpha: 0.1),
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
                        fontSize: 18,
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

                const SizedBox(height: 16),

                // Search Input
                TextField(
                  controller: widget.searchController,
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
                            if (widget.searchController.text
                                .trim()
                                .isNotEmpty) {
                              _searchForRecipe(widget.searchController.text);
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
        widget.searchController.text = label;
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
              color: Colors.black.withValues(alpha: 0.03),
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
}
