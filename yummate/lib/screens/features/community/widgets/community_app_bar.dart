import 'package:flutter/material.dart';

class CommunityAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final String searchQuery;
  final String selectedFilter;
  final ValueChanged<String?> onFilterChanged;
  final TabController tabController;
  final VoidCallback onTabChanged;

  const CommunityAppBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.tabController,
    required this.onTabChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
                  controller: searchController,
                  onChanged: onSearchChanged,
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
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: onSearchClear,
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
                        value: selectedFilter,
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
                        onChanged: onFilterChanged,
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
                        controller: tabController,
                        onTap: (index) => onTabChanged(),
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
    );
  }
}
