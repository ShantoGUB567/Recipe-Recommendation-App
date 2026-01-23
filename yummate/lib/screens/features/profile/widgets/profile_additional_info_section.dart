import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/additional_information/screen/additional_info_screen.dart';

class ProfileAdditionalInfoSection extends StatefulWidget {
  final String uid;

  const ProfileAdditionalInfoSection({super.key, required this.uid});

  @override
  State<ProfileAdditionalInfoSection> createState() => _ProfileAdditionalInfoSectionState();
}

class _ProfileAdditionalInfoSectionState extends State<ProfileAdditionalInfoSection> {
  late Future<Map<String, dynamic>?> _additionalInfoFuture;

  @override
  void initState() {
    super.initState();
    _additionalInfoFuture = _loadAdditionalInfo();
  }

  Future<Map<String, dynamic>?> _loadAdditionalInfo() async {
    try {
      final ref = FirebaseDatabase.instance.ref('user_profiles/${widget.uid}');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      debugPrint('Error loading additional info: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _additionalInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          // Show button to add info
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.health_and_safety_outlined,
                      size: 48,
                      color: Color(0xFF7CB342),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Health & Preferences',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'You should eat healthy foods to improve your health. Add your health and preference information.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => const AdditionalInformationScreen())
                              ?.then((_) {
                            // Refresh the data after returning
                            setState(() {
                              _additionalInfoFuture = _loadAdditionalInfo();
                            });
                          });
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Additional Information'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7CB342),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health & Preferences',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Age
                  if (data['age'] != null)
                    _buildInfoRow('Age', data['age']),
                  
                  if (data['age'] != null && data['gender'] != null)
                    const Divider(),

                  // Gender
                  if (data['gender'] != null)
                    _buildInfoRow('Gender', data['gender']),

                  if (data['gender'] != null && data['height'] != null)
                    const Divider(),

                  // Height & Weight
                  if (data['height'] != null && data['weight'] != null)
                    _buildInfoRow('Height / Weight', '${data['height']} cm / ${data['weight']} kg'),

                  if (data['height'] != null && data['activityLevel'] != null)
                    const Divider(),

                  // Activity Level
                  if (data['activityLevel'] != null)
                    _buildInfoRow('Activity Level', data['activityLevel']),

                  if (data['activityLevel'] != null && data['primaryGoal'] != null)
                    const Divider(),

                  // Primary Goal
                  if (data['primaryGoal'] != null)
                    _buildInfoRow('Primary Goal', data['primaryGoal']),

                  if (data['primaryGoal'] != null && data['dietaryPreferences'] != null)
                    const Divider(),

                  // Dietary Preferences
                  if (data['dietaryPreferences'] != null && (data['dietaryPreferences'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dietary Preferences',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: (data['dietaryPreferences'] as List).map<Widget>((diet) {
                            return Chip(
                              label: Text(diet),
                              backgroundColor: const Color(0xFF7CB342).withOpacity(0.2),
                              side: const BorderSide(color: Color(0xFF7CB342)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                  if (data['dietaryPreferences'] != null && (data['dietaryPreferences'] as List).isNotEmpty && (data['favorite_cuisines'] != null || data['calorieGoal'] != null))
                    const Divider(),

                  // Favorite Cuisines
                  if (data['favorite_cuisines'] != null && (data['favorite_cuisines'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Favorite Cuisines',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: (data['favorite_cuisines'] as List).map<Widget>((cuisine) {
                            return Chip(
                              label: Text(cuisine),
                              backgroundColor: const Color(0xFF7CB342).withOpacity(0.2),
                              side: const BorderSide(color: Color(0xFF7CB342)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                  if (data['favorite_cuisines'] != null && (data['favorite_cuisines'] as List).isNotEmpty && data['calorieGoal'] != null)
                    const Divider(),

                  // Spicy Level
                  if (data['calorieGoal'] != null)
                    _buildInfoRow('Spicy Level', '${data['calorieGoal']}/5 🌶️'),

                  if ((data['favorite_cuisines'] != null || data['calorieGoal'] != null) && data['allergies'] != null)
                    const Divider(),

                  // Allergies
                  if (data['allergies'] != null && (data['allergies'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Allergies',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: (data['allergies'] as List).map<Widget>((allergy) {
                            return Chip(
                              label: Text(allergy),
                              backgroundColor: Colors.red.shade100,
                              side: BorderSide(color: Colors.red.shade300),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                  if (data['allergies'] != null && (data['allergies'] as List).isNotEmpty && data['medicalConditions'] != null)
                    const Divider(),

                  // Medical Conditions
                  if (data['medicalConditions'] != null && (data['medicalConditions'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Medical Conditions',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: (data['medicalConditions'] as List).map<Widget>((condition) {
                            return Chip(
                              label: Text(condition),
                              backgroundColor: Colors.amber.shade100,
                              side: BorderSide(color: Colors.amber.shade400),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value.isNotEmpty ? value : '—',
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
