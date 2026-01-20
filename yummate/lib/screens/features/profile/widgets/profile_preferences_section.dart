import 'package:flutter/material.dart';

class ProfilePreferencesSection extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfilePreferencesSection({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
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
                'Preferences',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text('Spicy Level'),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color:
                              i < (userData['spicy_level'] ?? 2)
                                  ? Colors.orange
                                  : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Favorite Cuisines',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children:
                    (((userData['favorite_cuisines'] as List?) ?? []))
                        .map<Widget>(
                          (c) => Chip(label: Text(c)),
                        )
                        .toList(),
              ),
              const SizedBox(height: 12),
              const Text(
                'Allergies',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children:
                    (((userData['allergies'] as List?) ?? []))
                        .map<Widget>(
                          (a) => Chip(
                            label: Text(a),
                            backgroundColor: Colors.red.shade100,
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
