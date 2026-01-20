import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/home_screen.dart';
import 'package:yummate/screens/features/weekly_meal_planner_screen.dart';
import 'package:yummate/screens/features/community_screen.dart';
import 'package:yummate/screens/features/profile_screen.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final String? userName;

  const BottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.userName,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        // Home
        Get.offAll(
          () => HomeScreen(userName: widget.userName ?? 'User'),
          popGesture: false,
        );
        break;
      case 1:
        // Planner
        Get.offAll(
          () => const WeeklyMealPlannerScreen(),
          popGesture: false,
        );
        break;
      case 2:
        // Community
        Get.offAll(
          () => CommunityScreen(),
          popGesture: false,
        );
        break;
      case 3:
        // Profile
        Get.offAll(
          () => const ProfileScreen(),
          popGesture: false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      selectedItemColor: const Color(0xFF7CB342),
      unselectedItemColor: Colors.grey.shade500,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Planner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          activeIcon: Icon(Icons.group),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
