import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:yummate/models/post_model.dart';
import 'package:intl/intl.dart';

class PostDetailDialog extends StatefulWidget {
  final PostModel post;

  const PostDetailDialog({super.key, required this.post});

  @override
  State<PostDetailDialog> createState() => _PostDetailDialogState();
}

class _PostDetailDialogState extends State<PostDetailDialog> {
  late PostModel _post;
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  Future<void> _submitReview() async {
    final text = _commentController.text.trim();
    if (text.isEmpty && _rating == 0) {
      EasyLoading.showError('Please add a comment or rating');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        EasyLoading.showError('Please login to add review');
        return;
      }

      final userData = await _db.child('users').child(user.uid).get();
      final userName = userData.exists
          ? (userData.value as Map)['name'] ?? 'Anonymous'
          : 'Anonymous';

      final commentId =
          _db.child('posts').child(_post.id).child('comments').push().key ?? '';
      final comment = CommentModel(
        id: commentId,
        userId: user.uid,
        userName: userName,
        userPhotoUrl: null,
        text: text,
        rating: _rating,
        createdAt: DateTime.now(),
      );

      await _db
          .child('posts')
          .child(_post.id)
          .child('comments')
          .child(commentId)
          .set(comment.toJson());

      // Update average rating
      if (_rating > 0) {
        final currentRatings = _post.comments.map((c) => c.rating).toList();
        currentRatings.add(_rating);
        final avgRating =
            currentRatings.reduce((a, b) => a + b) / currentRatings.length;

        await _db.child('posts').child(_post.id).update({
          'averageRating': avgRating,
        });
      }

      if (mounted) {
        EasyLoading.showSuccess('Review added successfully');
      }

      _commentController.clear();
      setState(() => _rating = 0);
    } catch (e) {
      EasyLoading.showError('Error: ${e.toString().substring(0, 50)}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF7CB342),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
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
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'MMM dd, yyyy • hh:mm a',
                          ).format(_post.createdAt),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption
                  Text(
                    _post.caption,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 12),

                  // Image if exists
                  if (_post.imageUrl != null && _post.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _post.imageUrl!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Likes and dislikes
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '👍 ${_post.likeCount}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '👎 ${_post.unlikeCount}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Average rating
                  if (_post.averageRating > 0)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          _post.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Comments section
                  if (_post.comments.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      'Reviews & Ratings',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _post.comments.length,
                        itemBuilder: (context, index) {
                          final comment = _post.comments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: const Color(
                                        0xFF7CB342,
                                      ).withValues(alpha: 0.2),
                                      child: Text(
                                        (comment.userName.isNotEmpty)
                                            ? comment.userName[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.userName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (comment.rating > 0)
                                            Row(
                                              children: [
                                                ...List.generate(
                                                  5,
                                                  (i) => Icon(
                                                    Icons.star,
                                                    size: 14,
                                                    color:
                                                        i <
                                                            comment.rating
                                                                .toInt()
                                                        ? Colors.amber
                                                        : Colors.grey.shade300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment.text,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                  ],

                  // Add review section
                  const Text(
                    'Add Your Review',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),

                  // Rating selector
                  Row(
                    children: [
                      const Text('Rate: ', style: TextStyle(fontSize: 12)),
                      ...List.generate(
                        5,
                        (index) => GestureDetector(
                          onTap: () {
                            setState(() => _rating = (index + 1).toDouble());
                          },
                          child: Icon(
                            Icons.star,
                            size: 20,
                            color: index < _rating.toInt()
                                ? Colors.amber
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Comment input
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add your comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7CB342),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Submit Review',
                              style: TextStyle(color: Colors.white),
                            ),
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
