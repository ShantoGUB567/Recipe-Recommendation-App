import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:yummate/models/post_model.dart';
import 'package:yummate/core/widgets/post_widget.dart';
import 'package:yummate/core/widgets/post_card.dart';
import 'package:yummate/core/widgets/bottom_nav_bar.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  late Stream<List<PostModel>> _postsStream;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    _postsStream = _db.child('posts').onValue.map((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final posts = <PostModel>[];
        data.forEach((key, value) {
          final post = PostModel.fromJson(Map<String, dynamic>.from(value as Map));
          posts.add(post);
        });
        // Sort by date (newest first)
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return posts;
      }
      return <PostModel>[];
    }).asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: const Color(0xFF7CB342),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: _postsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PostWidget(),
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.post_add,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share your culinary story!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final posts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: posts.length + 1, // +1 for the post widget at top
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PostWidget(),
                );
              }

              final post = posts[index - 1];
              return PostCard(
                post: post,
                onSaved: () {
                  // Trigger refresh if needed
                  setState(() {});
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
