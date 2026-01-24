import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:io';
import 'package:yummate/models/post_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;
  String? _userName;
  String? _userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final snapshot = await _db.child('users').child(user.uid).get();
        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          setState(() {
            _userName = data['name'] ?? 'Anonymous';
            _userPhotoUrl = data['profileImageUrl'];
          });
        }
      } catch (e) {
        debugPrint('Error loading user data: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      EasyLoading.showError('Error picking image: $e');
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      // For now, we'll store the image path as base64 or as a local reference
      // In production, you'd use firebase_storage
      // For this demo, we'll just store the file path
      // You can implement firebase_storage later if needed
      return 'local_image_path'; // Placeholder
    } catch (e) {
      EasyLoading.showError('Error processing image: $e');
      return null;
    }
  }

  Future<void> _createPost() async {
    final caption = _captionController.text.trim();

    if (caption.isEmpty) {
      EasyLoading.showError('Please add a caption');
      return;
    }

    setState(() => _isLoading = true);
    EasyLoading.show(status: 'Creating post...');

    try {
      final user = _auth.currentUser;
      if (user == null) {
        EasyLoading.showError('Please login to create a post');
        return;
      }

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      final postId = _db.child('posts').push().key ?? '';
      debugPrint('Creating post with ID: $postId');

      final post = PostModel(
        id: postId,
        userId: user.uid,
        userName: _userName ?? 'Anonymous',
        userPhotoUrl: _userPhotoUrl,
        caption: caption,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        likedBy: [],
        likeCount: 0,
        unlikeCount: 0,
        comments: [],
        averageRating: 0.0,
      );

      final postData = post.toJson();
      debugPrint('Post data to save: $postData');

      await _db.child('posts').child(postId).set(postData);
      debugPrint('Post saved to database successfully');

      // Also save to user's posts
      await _db
          .child('users')
          .child(user.uid)
          .child('posts')
          .child(postId)
          .set(true);
      debugPrint('Post linked to user profile');

      EasyLoading.showSuccess('Post created successfully');

      // Go back to community screen
      Get.back();
    } catch (e) {
      debugPrint('Error creating post: $e');
      EasyLoading.showError('Error creating post: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          'Create Post',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isLoading ? null : _createPost,
              style: TextButton.styleFrom(
                backgroundColor: _isLoading
                    ? Colors.grey.shade300
                    : const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Divider
          Divider(height: 1, color: Colors.grey.shade300),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // User Avatar with gradient
                        Container(
                          width: 44,
                          height: 44,
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
                              (_userName?.isNotEmpty ?? false)
                                  ? _userName![0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName ?? 'Loading...',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.public,
                                    size: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Public',
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
                      ],
                    ),
                  ),

                  // Caption input - Facebook style
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: _captionController,
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
                  ),

                  const SizedBox(height: 8),

                  // Image preview section
                  if (_selectedImage != null)
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: 350,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () {
                                  setState(() => _selectedImage = null);
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.black87,
                                  size: 20,
                                ),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Add to post section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Add to your post',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        // Photo/Video button
                        InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _selectedImage == null
                                  ? const Color(0xFFFF6B35).withOpacity(0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.image,
                                  color: _selectedImage == null
                                      ? const Color(0xFFFF6B35)
                                      : Colors.grey.shade600,
                                  size: 24,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Photo',
                                  style: TextStyle(
                                    color: _selectedImage == null
                                        ? const Color(0xFFFF6B35)
                                        : Colors.grey.shade600,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
