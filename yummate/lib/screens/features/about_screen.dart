import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Yummate'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Yummate',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Yummate helps you discover recipes based on ingredients and photos.\n\nBuilt with love.\n',
            ),
            SizedBox(height: 18),
            Text('Contact', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('support@yummate.example'),
          ],
        ),
      ),
    );
  }
}
