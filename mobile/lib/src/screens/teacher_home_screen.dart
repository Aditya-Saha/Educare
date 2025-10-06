import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'my_courses_page.dart';       // 👈 ADD
import 'add_course_page.dart';      // 👈 ADD
import 'settings_page.dart';
import 'add_course_content_page.dart';
import 'custom_video_player_page.dart';  // 👈 ADD

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool isDarkMode = true;
  late AnimationController _iconAnimation;

  final List<Widget> _pages = const [
    MyCoursesPage(),
    AddCoursePage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _iconAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _iconAnimation.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      if (isDarkMode) {
        _iconAnimation.reverse();
      } else {
        _iconAnimation.forward();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF0F1724) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Teacher Panel", style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: AnimatedBuilder(
              animation: _iconAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _iconAnimation.value * 3.14,
                  child: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: textColor,
                  ),
                );
              },
            ),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.grey[100],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: isDarkMode ? Colors.white70 : Colors.black45,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'My Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Add Course'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.logout),
        tooltip: 'Logout',
      ),
    );
  }
}