import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Community',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Share recipes, ask questions and see posts from other food lovers.',
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('U${index + 1}')),
                    title: Text('User post #${index + 1}'),
                    subtitle: const Text('Love this recipe!'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
