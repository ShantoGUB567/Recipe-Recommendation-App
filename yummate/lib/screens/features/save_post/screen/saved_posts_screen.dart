import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:yummate/models/post_model.dart';
import 'package:yummate/core/widgets/post_card.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<List<PostModel>> _savedPostsStream;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() => _userId = user.uid);

      _savedPostsStream = _db
          .child('users')
          .child(user.uid)
          .child('savedPosts')
          .onValue
          .asyncMap((event) async {
            if (event.snapshot.exists) {
              final savedPostIds = List<String>.from(
                (event.snapshot.value as Map).keys,
              );
              final posts = <PostModel>[];

              for (final postId in savedPostIds) {
                try {
                  final postSnapshot = await _db
                      .child('posts')
                      .child(postId)
                      .get();
                  if (postSnapshot.exists) {
                    final post = PostModel.fromJson(
                      Map<String, dynamic>.from(postSnapshot.value as Map),
                    );
                    posts.add(post);
                  }
                } catch (e) {
                  debugPrint('Error fetching post $postId: $e');
                }
              }

              // Sort by date (newest first)
              posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return posts;
            }
            return <PostModel>[];
          })
          .asBroadcastStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Saved Posts'),
          backgroundColor: const Color(0xFF7CB342),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Please login to view saved posts',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts'),
        backgroundColor: const Color(0xFF7CB342),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: _savedPostsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved posts',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save posts to view them here',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          final posts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                onSaved: () {
                  setState(() {});
                },
              );
            },
          );
        },
      ),
    );
  }
}
