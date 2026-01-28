import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:yummate/models/recipe_model.dart';
import 'package:yummate/services/session_service.dart';
import 'package:yummate/services/recipe_service.dart';
import '../widgets/recipe_card.dart';

class GenerateRecipeScreen extends StatefulWidget {
  final List<RecipeModel> recipes;
  final String rawResponse;
  final String? query;
  final String type; // "search" or "generate"

  const GenerateRecipeScreen({
    super.key,
    required this.recipes,
    required this.rawResponse,
    this.query,
    this.type = "generate",
  });

  @override
  State<GenerateRecipeScreen> createState() => _GenerateRecipeScreenState();
}

class _GenerateRecipeScreenState extends State<GenerateRecipeScreen> {
  final SessionService _sessionService = SessionService();
  final RecipeService _recipeService = RecipeService();

  @override
  void initState() {
    super.initState();
    _saveSession();
  }

  Future<void> _saveSession() async {
    // Save to Firebase if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _recipeService.saveRecipeHistory(
          userId: user.uid,
          query: widget.query ?? 'Generated Recipes',
          type: widget.type,
          recipes: widget.recipes,
        );
      } catch (e) {
        debugPrint('Error saving history to Firebase: $e');
      }
    }

    // Also save to local session for caching purposes (optional)
    await _sessionService.saveGeneratedRecipeSession(
      recipes: widget.recipes,
      query: widget.query ?? 'Generated Recipes',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFFF6B35),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Recipes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${widget.recipes.length} recipes found',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFFF6B35), Colors.orange.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // Recipe List
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final recipe = widget.recipes[index];
                return RecipeCard(recipe: recipe, index: index);
              }, childCount: widget.recipes.length),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.back(),
        backgroundColor: const Color(0xFFFF6B35),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Recipe',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
