import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yummate/models/user_profile_model.dart';
import 'package:yummate/core/widgets/primary_button.dart';

class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  State<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isLoading = false;

  // Form data
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController medicalController = TextEditingController();

  String? selectedGender;
  String? selectedActivityLevel;
  String? selectedPrimaryGoal;
  List<String> selectedDietaryPreferences = [];

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active'
  ];
  final List<String> primaryGoals = [
    'Weight Loss',
    'Muscle Gain',
    'Maintenance'
  ];
  final List<String> dietaryOptions = ['Vegan', 'Keto', 'Paleo', 'Standard'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    allergiesController.dispose();
    medicalController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0: // Body Metrics
        return ageController.text.isNotEmpty &&
            selectedGender != null &&
            heightController.text.isNotEmpty &&
            weightController.text.isNotEmpty;
      case 1: // Activity Level
        return selectedActivityLevel != null;
      case 2: // Primary Goal
        return selectedPrimaryGoal != null;
      case 3: // Dietary Preferences
        return selectedDietaryPreferences.isNotEmpty;
      case 4: // Health Constraints
        return true; // Optional fields
      default:
        return false;
    }
  }

  Future<void> _saveProfile() async {
    if (!_validateCurrentPage()) {
      Get.snackbar('Error', 'Please complete all required fields',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final allergies =
          allergiesController.text.split(',').map((e) => e.trim()).toList();
      final medicalConditions =
          medicalController.text.split(',').map((e) => e.trim()).toList();

      final updatedProfile = UserProfile(
        uid: user.uid,
        age: ageController.text,
        gender: selectedGender!,
        height: heightController.text,
        weight: weightController.text,
        activityLevel: selectedActivityLevel!,
        primaryGoal: selectedPrimaryGoal!,
        dietaryPreferences: selectedDietaryPreferences,
        allergies: allergies.where((e) => e.isNotEmpty).toList(),
        medicalConditions: medicalConditions.where((e) => e.isNotEmpty).toList(),
        calorieGoal: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(user.uid)
          .set(updatedProfile.toJson());

      Get.snackbar('Success', 'Profile saved successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);

      // Navigate to home screen
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Complete Your Profile'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 5,
              minHeight: 4,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF7CB342),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  // Page 0: Body Metrics
                  _buildBodyMetricsPage(),
                  // Page 1: Activity Level
                  _buildActivityLevelPage(),
                  // Page 2: Primary Goal
                  _buildPrimaryGoalPage(),
                  // Page 3: Dietary Preferences
                  _buildDietaryPreferencesPage(),
                  // Page 4: Health Constraints
                  _buildHealthConstraintsPage(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                ElevatedButton(
                  onPressed: _previousPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Back'),
                )
              else
                const SizedBox(width: 80),
              if (_currentPage < 4)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: SizedBox(
                      height: 48,
                      child: PrimaryButton(
                        text: 'Next',
                        onPressed: _nextPage,
                        isEnabled: _validateCurrentPage(),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: SizedBox(
                      height: 48,
                      child: PrimaryButton(
                        text: 'Complete Profile',
                        onPressed: _saveProfile,
                        isEnabled: !_isLoading,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyMetricsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Body Metrics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your physical characteristics',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          // Age
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Age *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.calendar_today),
            ),
          ),
          const SizedBox(height: 16),
          // Gender
          DropdownButtonFormField<String>(
            value: selectedGender,
            items: genderOptions.map((gender) {
              return DropdownMenuItem(value: gender, child: Text(gender));
            }).toList(),
            onChanged: (value) {
              setState(() => selectedGender = value);
            },
            decoration: InputDecoration(
              labelText: 'Gender *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          // Height
          TextField(
            controller: heightController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Height (cm) *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.height),
            ),
          ),
          const SizedBox(height: 16),
          // Weight
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Weight (kg) *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.scale),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildActivityLevelPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Activity Level',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'How active are you in your daily life?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ...activityLevels.map((level) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RadioListTile<String>(
                value: level,
                groupValue: selectedActivityLevel,
                onChanged: (value) {
                  setState(() => selectedActivityLevel = value);
                },
                title: Text(level),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPrimaryGoalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Primary Goal',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'What is your primary fitness goal?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ...primaryGoals.map((goal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RadioListTile<String>(
                value: goal,
                groupValue: selectedPrimaryGoal,
                onChanged: (value) {
                  setState(() => selectedPrimaryGoal = value);
                },
                title: Text(goal),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDietaryPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Dietary Preferences',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select one or more dietary preferences',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dietaryOptions.map((diet) {
              final isSelected = selectedDietaryPreferences.contains(diet);
              return FilterChip(
                label: Text(diet),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedDietaryPreferences.add(diet);
                    } else {
                      selectedDietaryPreferences.remove(diet);
                    }
                  });
                },
                backgroundColor: Colors.transparent,
                selectedColor: const Color(0xFF7CB342).withOpacity(0.2),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF7CB342)
                      : Colors.grey[400]!,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHealthConstraintsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Health Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add any allergies or medical conditions (optional)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          // Allergies
          TextField(
            controller: allergiesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Allergies (comma separated)',
              hintText: 'e.g., Peanuts, Shellfish, Dairy',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.warning),
            ),
          ),
          const SizedBox(height: 16),
          // Medical Conditions
          TextField(
            controller: medicalController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Medical Conditions (comma separated)',
              hintText: 'e.g., Diabetes, Hypertension',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.local_hospital),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
