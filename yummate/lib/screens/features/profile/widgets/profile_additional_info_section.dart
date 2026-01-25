import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/additional_information/screen/additional_info_screen.dart';

class ProfileAdditionalInfoSection extends StatefulWidget {
  final String uid;

  const ProfileAdditionalInfoSection({super.key, required this.uid});

  @override
  State<ProfileAdditionalInfoSection> createState() =>
      _ProfileAdditionalInfoSectionState();
}

class _ProfileAdditionalInfoSectionState
    extends State<ProfileAdditionalInfoSection> {
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

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          // Show button to add info
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.health_and_safety_outlined,
                      size: 40,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Health & Preferences',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your health and dietary preferences for personalized meal recommendations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.to(() => const AdditionalInformationScreen())?.then(
                          (_) {
                            // Refresh the data after returning
                            setState(() {
                              _additionalInfoFuture = _loadAdditionalInfo();
                            });
                          },
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text(
                        'Add Information',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.health_and_safety_outlined,
                        color: Color(0xFFFF6B35),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Health & Preferences',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Get.to(() => const AdditionalInformationScreen())?.then(
                          (_) {
                            setState(() {
                              _additionalInfoFuture = _loadAdditionalInfo();
                            });
                          },
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: const Color(0xFFFF6B35),
                      tooltip: 'Edit',
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: Colors.grey.shade200),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Age
                    if (data['age'] != null) _buildInfoRow('Age', data['age']),

                    if (data['age'] != null && data['gender'] != null)
                      const SizedBox(height: 12),

                    // Gender
                    if (data['gender'] != null)
                      _buildInfoRow('Gender', data['gender']),

                    if (data['gender'] != null && data['height'] != null)
                      const SizedBox(height: 12),

                    // Height & Weight
                    if (data['height'] != null && data['weight'] != null)
                      _buildInfoRow(
                        'Height / Weight',
                        '${data['height']} cm / ${data['weight']} kg',
                      ),

                    if (data['height'] != null && data['activityLevel'] != null)
                      const SizedBox(height: 12),

                    // Activity Level
                    if (data['activityLevel'] != null)
                      _buildInfoRow('Activity Level', data['activityLevel']),

                    if (data['activityLevel'] != null &&
                        data['primaryGoal'] != null)
                      const SizedBox(height: 12),

                    // Primary Goal
                    if (data['primaryGoal'] != null)
                      _buildInfoRow('Primary Goal', data['primaryGoal']),

                    if (data['primaryGoal'] != null &&
                        data['dietaryPreferences'] != null)
                      const SizedBox(height: 16),

                    // Dietary Preferences
                    if (data['dietaryPreferences'] != null &&
                        (data['dietaryPreferences'] as List).isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dietary Preferences',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (data['dietaryPreferences'] as List)
                                .map<Widget>((diet) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFF6B35,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFFF6B35,
                                        ).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      diet,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFFF6B35),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ],
                      ),

                    if (data['dietaryPreferences'] != null &&
                        (data['dietaryPreferences'] as List).isNotEmpty &&
                        (data['favorite_cuisines'] != null ||
                            data['calorieGoal'] != null))
                      const SizedBox(height: 16),

                    // Favorite Cuisines
                    if (data['favorite_cuisines'] != null &&
                        (data['favorite_cuisines'] as List).isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Favorite Cuisines',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (data['favorite_cuisines'] as List)
                                .map<Widget>((cuisine) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFF6B35,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFFF6B35,
                                        ).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      cuisine,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFFF6B35),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ],
                      ),

                    if (data['favorite_cuisines'] != null &&
                        (data['favorite_cuisines'] as List).isNotEmpty &&
                        data['calorieGoal'] != null)
                      const SizedBox(height: 12),

                    // Spicy Level
                    if (data['calorieGoal'] != null)
                      _buildInfoRow(
                        'Spicy Level',
                        '${data['calorieGoal']}/5 🌶️',
                      ),

                    if ((data['favorite_cuisines'] != null ||
                            data['calorieGoal'] != null) &&
                        data['allergies'] != null)
                      const SizedBox(height: 16),

                    // Allergies
                    if (data['allergies'] != null &&
                        (data['allergies'] as List).isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Allergies',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (data['allergies'] as List).map<Widget>((
                              allergy,
                            ) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.red.shade300,
                                  ),
                                ),
                                child: Text(
                                  allergy,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                    if (data['allergies'] != null &&
                        (data['allergies'] as List).isNotEmpty &&
                        data['medicalConditions'] != null)
                      const SizedBox(height: 16),

                    // Medical Conditions
                    if (data['medicalConditions'] != null &&
                        (data['medicalConditions'] as List).isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medical Conditions',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (data['medicalConditions'] as List)
                                .map<Widget>((condition) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.amber.shade400,
                                      ),
                                    ),
                                    child: Text(
                                      condition,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.amber.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value.isNotEmpty ? value : '—',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
