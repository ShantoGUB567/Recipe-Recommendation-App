import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/features/home/screen/home_screen.dart';
import 'package:yummate/screens/features/meal_planner/screen/weekly_meal_planner_screen.dart';
import 'package:yummate/screens/features/community/screen/community_screen.dart';
import 'package:yummate/screens/features/profile/screen/profile_screen.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final String? userName;

  const BottomNavBar({super.key, this.currentIndex = 0, this.userName});

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
        Get.offAll(() => const WeeklyMealPlannerScreen(), popGesture: false);
        break;
      case 2:
        // Community
        Get.offAll(() => CommunityScreen(), popGesture: false);
        break;
      case 3:
        // Profile
        Get.offAll(() => const ProfileScreen(), popGesture: false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFF6B35),
        unselectedItemColor: Colors.grey.shade500,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        elevation: 0,
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
      ),
    );
  }
}
