import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:yummate/models/post_model.dart';
import 'package:yummate/core/widgets/post_detail_dialog.dart';
import 'package:intl/intl.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onSaved;

  const PostCard({
    super.key,
    required this.post,
    required this.onSaved,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late PostModel _post;
  bool _isLiked = false;
  bool _isSaved = false;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _checkLikeStatus();
    _checkSavedStatus();
  }

  Future<void> _checkLikeStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot =
          await _db.child('posts').child(_post.id).child('likedBy').get();
      if (snapshot.exists) {
        final likedBy = List<String>.from(snapshot.value as List);
        setState(() => _isLiked = likedBy.contains(user.uid));
      }
    }
  }

  Future<void> _checkSavedStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _db
          .child('users')
          .child(user.uid)
          .child('savedPosts')
          .child(_post.id)
          .get();
      setState(() => _isSaved = snapshot.exists);
    }
  }

  Future<void> _toggleLike() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to like posts')),
      );
      return;
    }

    try {
      if (_isLiked) {
        // Unlike
        await _db
            .child('posts')
            .child(_post.id)
            .child('likedBy')
            .child(user.uid)
            .remove();
        await _db.child('posts').child(_post.id).update({
          'likeCount': _post.likeCount - 1,
        });
        setState(() {
          _isLiked = false;
          _post = PostModel(
            id: _post.id,
            userId: _post.userId,
            userName: _post.userName,
            userPhotoUrl: _post.userPhotoUrl,
            caption: _post.caption,
            imageUrl: _post.imageUrl,
            createdAt: _post.createdAt,
            likedBy: _post.likedBy..remove(user.uid),
            likeCount: _post.likeCount - 1,
            unlikeCount: _post.unlikeCount,
            comments: _post.comments,
            averageRating: _post.averageRating,
          );
        });
      } else {
        // Like
        await _db
            .child('posts')
            .child(_post.id)
            .child('likedBy')
            .child(user.uid)
            .set(true);
        await _db.child('posts').child(_post.id).update({
          'likeCount': _post.likeCount + 1,
        });
        setState(() {
          _isLiked = true;
          _post = PostModel(
            id: _post.id,
            userId: _post.userId,
            userName: _post.userName,
            userPhotoUrl: _post.userPhotoUrl,
            caption: _post.caption,
            imageUrl: _post.imageUrl,
            createdAt: _post.createdAt,
            likedBy: [..._post.likedBy, user.uid],
            likeCount: _post.likeCount + 1,
            unlikeCount: _post.unlikeCount,
            comments: _post.comments,
            averageRating: _post.averageRating,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _toggleSave() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save posts')),
      );
      return;
    }

    try {
      if (_isSaved) {
        await _db
            .child('users')
            .child(user.uid)
            .child('savedPosts')
            .child(_post.id)
            .remove();
        setState(() => _isSaved = false);
      } else {
        await _db
            .child('users')
            .child(user.uid)
            .child('savedPosts')
            .child(_post.id)
            .set(DateTime.now().toIso8601String());
        setState(() => _isSaved = true);
      }
      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showPostDetail() {
    showDialog(
      context: context,
      builder: (context) => PostDetailDialog(post: _post),
    ).then((_) {
      // Refresh post data
      _checkLikeStatus();
    });
  }

  String _truncateCaption(String caption, {int maxLength = 150}) {
    if (caption.length > maxLength) {
      return caption.substring(0, maxLength) + '...';
    }
    return caption;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF7CB342).withOpacity(0.2),
                  child: Text(
                    (_post.userName.isNotEmpty)
                        ? _post.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7CB342),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(_post.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Report'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'report') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post reported')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Caption
          GestureDetector(
            onTap: _showPostDetail,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _truncateCaption(_post.caption),
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                  if (_post.caption.length > 150)
                    GestureDetector(
                      onTap: _showPostDetail,
                      child: const Text(
                        'See more',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Image if exists
          if (_post.imageUrl != null && _post.imageUrl!.isNotEmpty)
            GestureDetector(
              onTap: _showPostDetail,
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade100,
                child: Image.network(
                  _post.imageUrl!,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Likes and ratings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                if (_post.likeCount > 0)
                  Text(
                    '👍 ${_post.likeCount}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                const SizedBox(width: 8),
                if (_post.unlikeCount > 0)
                  Text(
                    '👎 ${_post.unlikeCount}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                const Spacer(),
                if (_post.averageRating > 0)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        _post.averageRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const Divider(height: 8),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  label: 'Like',
                  color: _isLiked ? Colors.blue : Colors.grey,
                  onTap: _toggleLike,
                ),
                _buildActionButton(
                  icon: Icons.thumb_down_outlined,
                  label: 'Unlike',
                  color: Colors.grey,
                  onTap: () {
                    // Unlike logic
                  },
                ),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: 'Review',
                  color: Colors.grey,
                  onTap: _showPostDetail,
                ),
                _buildActionButton(
                  icon: _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  label: 'Save',
                  color: _isSaved ? Colors.amber : Colors.grey,
                  onTap: _toggleSave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}
