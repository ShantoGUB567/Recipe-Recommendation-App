import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yummate/models/post_model.dart';
import 'package:yummate/core/widgets/post_widget.dart';
import 'package:yummate/core/widgets/post_card.dart';
import 'package:yummate/core/widgets/bottom_nav_bar.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Recent'; // Recent, Popular, Top Rated

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<PostModel>> _getPostsStream() {
    return _db.child('posts').onValue.map((event) {
      debugPrint('📡 Posts stream updated');
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        debugPrint('✅ Found ${data.length} posts in database');
        final posts = <PostModel>[];
        data.forEach((key, value) {
          try {
            final postData = Map<String, dynamic>.from(value as Map);
            final post = PostModel.fromJson(postData);
            posts.add(post);
            debugPrint('✅ Parsed post: ${post.id} by ${post.userName}');
          } catch (e) {
            debugPrint('❌ Error parsing post $key: $e');
            debugPrint('Post data: $value');
          }
        });

        debugPrint('📊 Total parsed posts: ${posts.length}');

        debugPrint('📊 Total parsed posts: ${posts.length}');

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          debugPrint('🔍 Applying search filter: $_searchQuery');
          posts.removeWhere(
            (post) =>
                !post.caption.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) &&
                !post.userName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          );
          debugPrint('📊 Posts after search: ${posts.length}');
        }

        // Apply tab filter
        if (_tabController.index == 1) {
          debugPrint('👥 Filtering for Following tab');
          // Following tab - implement following logic
          // For now, show all posts
        } else if (_tabController.index == 2) {
          debugPrint('👤 Filtering for My Posts tab');
          // My Posts tab
          final currentUserId = _auth.currentUser?.uid;
          if (currentUserId != null) {
            posts.removeWhere((post) => post.userId != currentUserId);
            debugPrint('📊 My posts: ${posts.length}');
          }
        }

        // Sort based on filter
        debugPrint('🔄 Sorting by: $_selectedFilter');
        switch (_selectedFilter) {
          case 'Recent':
            posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            break;
          case 'Popular':
            posts.sort((a, b) => b.likeCount.compareTo(a.likeCount));
            break;
          case 'Top Rated':
            posts.sort((a, b) => b.averageRating.compareTo(a.averageRating));
            break;
        }

        debugPrint('📤 Returning ${posts.length} posts to UI');
        return posts;
      }
      debugPrint('⚠️ No posts found in database');
      return <PostModel>[];
    }).asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          'Community',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Search bar
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(23),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search posts, recipes, users...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFFF6B35),
                        size: 22,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Filter and Tabs
                Row(
                  children: [
                    // Filter Dropdown
                    Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          icon: const Icon(
                            Icons.tune,
                            color: Color(0xFFFF6B35),
                            size: 16,
                          ),
                          style: const TextStyle(
                            color: Color(0xFFFF6B35),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          items: ['Recent', 'Popular', 'Top Rated'].map((
                            value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() => _selectedFilter = newValue);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Tabs
                    Expanded(
                      child: Container(
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          onTap: (index) => setState(() {}),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          indicator: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: const [
                            Tab(text: 'All'),
                            Tab(text: 'Following'),
                            Tab(text: 'My Posts'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: _getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const PostWidget(),
                  const SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No results for \"$_searchQuery\"'
                              : 'Share your culinary story!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final posts = snapshot.data!;

          return RefreshIndicator(
            color: const Color(0xFFFF6B35),
            onRefresh: () async {
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: posts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: PostWidget(),
                  );
                }

                final post = posts[index - 1];
                return PostCard(post: post, onSaved: () => setState(() {}));
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
