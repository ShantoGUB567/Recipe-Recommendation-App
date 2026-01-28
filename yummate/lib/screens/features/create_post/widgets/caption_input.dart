import 'package:flutter/material.dart';

class CaptionInput extends StatelessWidget {
  final TextEditingController controller;

  const CaptionInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        minLines: 5,
        maxLength: 5000,
        autofocus: true,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: "What's cooking today?",
          hintStyle: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade500,
          ),
          border: InputBorder.none,
          counterStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
