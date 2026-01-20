import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:yummate/services/recipe_service.dart';
import 'package:yummate/screens/recipe_details_screen.dart';
import 'package:yummate/models/saved_recipe_model.dart';

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  final RecipeService _recipeService = RecipeService();
  late Stream<List<SavedRecipeModel>> _savedRecipesStream;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
        _savedRecipesStream = _recipeService.streamSavedRecipes(user.uid);
      });
    }
  }

  Future<void> _removeSavedRecipe(String recipeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _recipeService.removeSavedRecipe(
        userId: user.uid,
        recipeId: recipeId,
      );
      EasyLoading.showSuccess('Recipe removed from saved');
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Saved Recipes'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Please login to view saved recipes',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<SavedRecipeModel>>(
        stream: _savedRecipesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved recipes yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save recipes to view them here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          final savedRecipes = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final savedRecipe = savedRecipes[index];
              final recipe = savedRecipe.recipe;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFF6B35).withOpacity(0.2),
                    child: const Icon(
                      Icons.bookmark,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  title: Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    recipe.preparationTime,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 18),
                            SizedBox(width: 8),
                            Text('Remove'),
                          ],
                        ),
                        onTap: () =>
                            _removeSavedRecipe(savedRecipe.id),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsScreen(
                          recipe: recipe,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: savedRecipes.length,
          );
        },
      ),
    );
  }
}
