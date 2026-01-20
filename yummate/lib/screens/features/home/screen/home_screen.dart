import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:yummate/core/widgets/app_drawer.dart';
import 'package:yummate/core/widgets/bottom_nav_bar.dart';
import 'package:yummate/screens/features/save_recipe/screen/saved_recipes_screen.dart';
import 'package:yummate/services/gemini_service.dart';
import 'package:yummate/screens/features/home/widgets/home_hero_section.dart';
import 'package:yummate/screens/features/home/widgets/home_quick_access_section.dart';
import 'package:yummate/screens/features/home/widgets/home_search_tab.dart';
import 'package:yummate/screens/features/home/widgets/home_ingredients_tab.dart';

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
  late TabController _tabController;
  String _displayName = '';
  String? _userEmail;

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
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      debugPrint('[HOME_SCREEN] Current user UID: ${currentUser.uid}');
      debugPrint('[HOME_SCREEN] Current user email: ${currentUser.email}');
      debugPrint('[HOME_SCREEN] Widget userName param: ${widget.userName}');

      try {
        final dbRef = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(currentUser.uid);

        final snapshot = await dbRef.get();

        if (snapshot.exists) {
          final userData = snapshot.value as Map<dynamic, dynamic>;
          final fetchedName = userData['name'] ?? userData['username'] ?? 'User';
          final fetchedEmail = userData['email'] as String?;

          debugPrint('[HOME_SCREEN] Fetched from Firebase:');
          debugPrint('[HOME_SCREEN] Name: $fetchedName');
          debugPrint('[HOME_SCREEN] Email: $fetchedEmail');

          if (mounted) {
            setState(() {
              _displayName = fetchedName;
              _userEmail = fetchedEmail;
            });
          }
        } else {
          debugPrint('[HOME_SCREEN] No user data found in Firebase');
          if (mounted) {
            setState(() {
              _displayName = widget.userName.isNotEmpty ? widget.userName : 'User';
              _userEmail = currentUser.email;
            });
          }
        }
      } catch (e) {
        debugPrint('[HOME_SCREEN] Error fetching user data: $e');
        if (mounted) {
          setState(() {
            _displayName = widget.userName.isNotEmpty ? widget.userName : 'User';
            _userEmail = currentUser.email;
          });
        }
      }
    } else {
      debugPrint('[HOME_SCREEN] No current user found');
    }
  }

  @override
  void dispose() {
    ingredientController.dispose();
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
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
            onPressed: () => Get.to(() => const SavedRecipesScreen()),
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
      drawer: AppDrawer(userName: _displayName, userEmail: _userEmail),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            HomeHeroSection(displayName: _displayName),

            const SizedBox(height: 20),

            // Quick Access Section
            const HomeQuickAccessSection(),

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
                            children: const [
                              Icon(Icons.search_rounded, size: 20),
                              SizedBox(width: 8),
                              Text("Search"),
                            ],
                          ),
                        ),
                        Tab(
                          height: 48,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.restaurant, size: 20),
                              SizedBox(width: 8),
                              Text("Ingredients"),
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
                        HomeSearchTab(
                          searchController: searchController,
                          cuisineList: cuisineList,
                          geminiService: _geminiService,
                          onSearchSuccess: (query) {
                            // Callback if needed
                          },
                        ),

                        // Ingredients Tab
                        HomeIngredientsTab(
                          ingredientController: ingredientController,
                          initialIngredients: ingredients,
                          cuisineList: cuisineList,
                          geminiService: _geminiService,
                          onIngredientsChanged: (updatedIngredients) {
                            setState(() {
                              ingredients.clear();
                              ingredients.addAll(updatedIngredients);
                            });
                          },
                          onImageChanged: (image) {
                            setState(() {
                              pickedImage = image;
                            });
                          },
                        ),
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
}
