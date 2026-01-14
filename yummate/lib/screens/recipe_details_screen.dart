import 'package:flutter/material.dart';
import 'package:yummate/models/recipe_model.dart';
import 'package:yummate/services/session_service.dart';
import 'package:share_plus/share_plus.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final RecipeModel recipe;
  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  bool isMetric = true;
  final Set<int> checkedIngredients = {};
  final SessionService _sessionService = SessionService();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
    // Save to recent recipes
    _sessionService.saveRecentRecipe(widget.recipe);
  }

  Future<void> _loadSessionData() async {
    // Load favorite status
    final favorite = await _sessionService.isFavorite(widget.recipe.name);
    // Load checked ingredients
    final checked = await _sessionService.getCheckedIngredients(
      widget.recipe.name,
    );
    setState(() {
      isFavorite = favorite;
      checkedIngredients.addAll(checked);
    });
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      await _sessionService.removeFavoriteRecipe(widget.recipe.name);
    } else {
      await _sessionService.saveFavoriteRecipe(widget.recipe);
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  Future<void> _saveCheckedIngredients() async {
    await _sessionService.saveCheckedIngredients(
      widget.recipe.name,
      checkedIngredients,
    );
  }

  void _shareRecipe() {
    final ingredients = widget.recipe.ingredients.join('\n• ');
    final instructions = widget.recipe.instructions
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');

    Share.share(
      '${widget.recipe.name}\n\n'
      'Time: ${widget.recipe.preparationTime}\n'
      'Servings: ${widget.recipe.servings}\n'
      'Calories: ${widget.recipe.calories}\n\n'
      'Ingredients:\n• $ingredients\n\n'
      'Instructions:\n$instructions',
      subject: widget.recipe.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B35),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.recipe.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // White Title Section
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipe.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.recipe.preparationTime,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            // Icon Buttons Row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircularButton(
                    icon: Icons.favorite,
                    label: '${widget.recipe.calories}\nCalories',
                    color: const Color(0xFFFF6B35),
                    onTap: _toggleFavorite,
                    isFilled: isFavorite,
                  ),
                  _buildCircularButton(
                    icon: Icons.restaurant_menu,
                    label: '${widget.recipe.servings}\nServings',
                    color: const Color(0xFFFF8C42),
                    onTap: () {},
                  ),
                  _buildCircularButton(
                    icon: Icons.share,
                    label: 'Share\nrecipe',
                    color: const Color(0xFF4CAF50),
                    onTap: _shareRecipe,
                  ),
                  _buildCircularButton(
                    icon: Icons.print,
                    label: 'Print\nRecipe',
                    color: const Color(0xFF9C27B0),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Ingredients Header with angled design
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(color: Color(0xFFFF6B35)),
                  child: Row(
                    children: [
                      const Icon(Icons.menu, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Ingredients Required',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.recipe.ingredients.length}\nItems',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Angled shape
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: ClipPath(
                    clipper: _AngledClipper(),
                    child: Container(width: 80, color: const Color(0xFFFF8C42)),
                  ),
                ),
              ],
            ),

            // Ingredients List
            Container(
              color: Colors.white,
              child: Column(
                children: widget.recipe.ingredients.asMap().entries.map((
                  entry,
                ) {
                  final index = entry.key;
                  final ingredient = entry.value;
                  return _buildIngredientItem(index, ingredient);
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Directions Header with angled design
            if (widget.recipe.instructions.isNotEmpty) ...[
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(color: Color(0xFFFF6B35)),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.double_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Directions to Prepare',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${widget.recipe.instructions.length}\nSteps',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Angled shape
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: ClipPath(
                      clipper: _AngledClipper(),
                      child: Container(
                        width: 80,
                        color: const Color(0xFFFF8C42),
                      ),
                    ),
                  ),
                ],
              ),

              // Instructions List
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.recipe.instructions.asMap().entries.map((
                    entry,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step number circle
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Step instruction
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade800,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isFilled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(int index, String ingredient) {
    final isChecked = checkedIngredients.contains(index);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Green circular add button
          GestureDetector(
            onTap: () {
              setState(() {
                if (isChecked) {
                  checkedIngredients.remove(index);
                } else {
                  checkedIngredients.add(index);
                }
                _saveCheckedIngredients();
              });
            },
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isChecked
                    ? Colors.grey.shade400
                    : const Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isChecked ? Icons.check : Icons.add,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Ingredient text
          Expanded(
            child: Text(
              ingredient,
              style: TextStyle(
                fontSize: 15,
                color: isChecked ? Colors.grey.shade500 : Colors.black87,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                decorationColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper for angled section headers
class _AngledClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(20, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
