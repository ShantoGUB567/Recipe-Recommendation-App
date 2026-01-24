import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:yummate/models/post_model.dart';
import 'package:yummate/core/widgets/post_detail_dialog.dart';
import 'package:intl/intl.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onSaved;

  const PostCard({super.key, required this.post, required this.onSaved});

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
      final snapshot = await _db
          .child('posts')
          .child(_post.id)
          .child('likedBy')
          .get();
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
      return '${caption.substring(0, maxLength)}...';
    }
    return caption;
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }

  void _editPost() {
    final TextEditingController captionController = TextEditingController(
      text: _post.caption,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post'),
        content: TextField(
          controller: captionController,
          decoration: const InputDecoration(
            hintText: 'Enter your caption...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          maxLength: 500,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newCaption = captionController.text.trim();
              if (newCaption.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Caption cannot be empty')),
                );
                return;
              }

              try {
                // Update post in database
                await _db.child('posts').child(_post.id).update({
                  'caption': newCaption,
                  'updatedAt': DateTime.now().toIso8601String(),
                });

                setState(() {
                  _post = PostModel(
                    id: _post.id,
                    userId: _post.userId,
                    userName: _post.userName,
                    userPhotoUrl: _post.userPhotoUrl,
                    caption: newCaption,
                    imageUrl: _post.imageUrl,
                    createdAt: _post.createdAt,
                    likedBy: _post.likedBy,
                    likeCount: _post.likeCount,
                    unlikeCount: _post.unlikeCount,
                    comments: _post.comments,
                    averageRating: _post.averageRating,
                  );
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post updated successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update post: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                final userId = _auth.currentUser?.uid;
                if (userId == null) return;

                // Delete from posts collection
                await _db.child('posts').child(_post.id).remove();

                // Delete from user's posts
                await _db
                    .child('users')
                    .child(userId)
                    .child('posts')
                    .child(_post.id)
                    .remove();

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete post: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
            child: Row(
              children: [
                // User Avatar
                ClipOval(
                  child:
                      _post.userPhotoUrl != null &&
                          _post.userPhotoUrl!.isNotEmpty
                      ? Image.network(
                          _post.userPhotoUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B35),
                                    Color(0xFFFF8C42),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  (_post.userName.isNotEmpty)
                                      ? _post.userName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (_post.userName.isNotEmpty)
                                  ? _post.userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _post.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          if (_post.averageRating >= 4.5) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: Color(0xFFFF6B35),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            _getTimeAgo(_post.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.public,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_horiz, color: Colors.grey.shade600),
                  itemBuilder: (context) {
                    final currentUserId = _auth.currentUser?.uid;
                    final isOwner = currentUserId == _post.userId;

                    if (isOwner) {
                      // Show Edit and Delete for own posts
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 12),
                              Text('Edit post'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Delete post',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ];
                    } else {
                      // Show Save and Report for others' posts
                      return [
                        const PopupMenuItem(
                          value: 'save',
                          child: Row(
                            children: [
                              Icon(Icons.bookmark_outline, size: 20),
                              SizedBox(width: 12),
                              Text('Save post'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              Icon(Icons.flag_outlined, size: 20),
                              SizedBox(width: 12),
                              Text('Report'),
                            ],
                          ),
                        ),
                      ];
                    }
                  },
                  onSelected: (value) {
                    if (value == 'save') {
                      _toggleSave();
                    } else if (value == 'report') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post reported')),
                      );
                    } else if (value == 'edit') {
                      _editPost();
                    } else if (value == 'delete') {
                      _deletePost();
                    }
                  },
                ),
              ],
            ),
          ),

          // Caption
          if (_post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: GestureDetector(
                onTap: _showPostDetail,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _truncateCaption(_post.caption, maxLength: 200),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                    if (_post.caption.length > 200) const SizedBox(height: 4),
                    if (_post.caption.length > 200)
                      const Text(
                        'See more',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Image if exists
          if (_post.imageUrl != null && _post.imageUrl!.isNotEmpty)
            GestureDetector(
              onTap: _showPostDetail,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 500),
                color: Colors.black,
                child: Image.network(
                  _post.imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Reaction counts and stats
          if (_post.likeCount > 0 || _post.comments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Row(
                children: [
                  // Like count with emoji
                  if (_post.likeCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.thumb_up,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_post.likeCount}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Comments count
                  if (_post.comments.isNotEmpty)
                    GestureDetector(
                      onTap: _showPostDetail,
                      child: Text(
                        '${_post.comments.length} comment${_post.comments.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  // Rating
                  if (_post.averageRating > 0) ...[
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _post.averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(height: 1, color: Colors.grey.shade300),
          ),

          // Action buttons - Facebook style
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: _buildFacebookActionButton(
                    icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    label: 'Like',
                    color: _isLiked
                        ? const Color(0xFFFF6B35)
                        : Colors.grey.shade700,
                    onTap: _toggleLike,
                  ),
                ),
                Expanded(
                  child: _buildFacebookActionButton(
                    icon: Icons.mode_comment_outlined,
                    label: 'Comment',
                    color: Colors.grey.shade700,
                    onTap: _showPostDetail,
                  ),
                ),
                Expanded(
                  child: _buildFacebookActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    color: Colors.grey.shade700,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sharing feature coming soon!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _buildFacebookActionButton(
                    icon: _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    label: 'Save',
                    color: _isSaved
                        ? const Color(0xFFFF6B35)
                        : Colors.grey.shade700,
                    onTap: _toggleSave,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacebookActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
