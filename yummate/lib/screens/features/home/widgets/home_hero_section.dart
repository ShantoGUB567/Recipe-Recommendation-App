import 'package:flutter/material.dart';

class HomeHeroSection extends StatelessWidget {
  final String displayName;

  const HomeHeroSection({
    super.key,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                  height: 1.3,
                ),
                children: [
                  const TextSpan(text: "Hello "),
                  TextSpan(
                    text: displayName.isNotEmpty ? displayName : 'User',
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
                  const TextSpan(text: "! 👋\n"),
                  TextSpan(
                    text: "What's cooking today?",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
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
