import 'package:flutter/material.dart';

class ProfileInfoSection extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String uid;

  const ProfileInfoSection({
    super.key,
    required this.userData,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
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
                    Icons.person_outline,
                    color: Color(0xFFFF6B35),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // Info Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.account_circle_outlined,
                  "Username",
                  userData['username'] ?? "",
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.phone_outlined,
                  "Phone",
                  userData['phone'] ?? "",
                ),
                if (userData['location'] != null &&
                    userData['location'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    "Location",
                    userData['location'] ?? "",
                  ),
                ],
                if (userData['cookingLevel'] != null &&
                    userData['cookingLevel'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.local_dining_outlined,
                    "Cooking Level",
                    userData['cookingLevel'] ?? "",
                  ),
                ],
                if (userData['specialtyDishes'] != null &&
                    userData['specialtyDishes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.stars_outlined,
                    "Signature Dishes",
                    userData['specialtyDishes'] ?? "",
                  ),
                ],
                if (userData['bio'] != null &&
                    userData['bio'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.info_outline,
                    "Bio",
                    userData['bio'] ?? "",
                  ),
                ],
                if (userData['foodPhilosophy'] != null &&
                    userData['foodPhilosophy'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.lightbulb_outline,
                    "Food Philosophy",
                    userData['foodPhilosophy'] ?? "",
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isNotEmpty ? value : "Not set",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: value.isNotEmpty
                      ? Colors.black87
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
