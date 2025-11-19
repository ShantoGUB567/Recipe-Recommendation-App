import 'package:flutter/material.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // placeholder list of saved recipes
    final saved = <Map<String, String>>[
      {'name': 'Avocado Toast', 'subtitle': 'Quick breakfast'},
      {'name': 'Spicy Tofu Stir-fry', 'subtitle': '20 min'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: saved.isEmpty
          ? const Center(child: Text('No saved recipes yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final item = saved[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.orange.shade100, child: const Icon(Icons.bookmark)),
                    title: Text(item['name']!),
                    subtitle: Text(item['subtitle']!),
                    onTap: () {},
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: saved.length,
            ),
    );
  }
}
