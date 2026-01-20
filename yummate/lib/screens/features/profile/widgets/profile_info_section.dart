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
            children: [
              _buildInfoRow("Username", userData['username'] ?? ""),
              const Divider(),
              _buildInfoRow("Phone", userData['phone'] ?? ""),
              const Divider(),
              _buildInfoRow("UID", uid),
            ],
          ),
        ),
      ),
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
            value.isNotEmpty ? value : "—",
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
