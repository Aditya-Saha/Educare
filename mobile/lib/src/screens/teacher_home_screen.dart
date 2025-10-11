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
  final VoidCallback? onThemeToggle;

  const TeacherHomeScreen({super.key, this.onThemeToggle});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    MyCoursesPage(),
    AddCoursePage(),
    SettingsPage(),
  ];

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF030303);
    final hintColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF606060);
    final bottomBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appBarColor,
        title: Text(
          "Teacher Panel",
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: textColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("No new notifications"),
                  backgroundColor: isDark
                      ? const Color(0xFF313131)
                      : Colors.grey.shade300,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: "Notifications",
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: textColor,
            ),
            onPressed: () {
              if (widget.onThemeToggle != null) {
                widget.onThemeToggle!();
                // Show feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      Theme.of(context).brightness == Brightness.dark
                          ? "Switched to dark mode"
                          : "Switched to light mode",
                    ),
                    backgroundColor: isDark
                        ? const Color(0xFF313131)
                        : Colors.grey.shade300,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(milliseconds: 500),
                  ),
                );
              }
            },
            tooltip: "Toggle Theme",
          ),
        ],
      ),
      body: Container(
        color: bgColor,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bottomBarColor,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? const Color(0xFF313131)
                  : const Color(0xFFE0E0E0),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: bottomBarColor,
          elevation: 0,
          selectedItemColor: Colors.blue.shade600,
          unselectedItemColor: hintColor,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'My Courses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              activeIcon: Icon(Icons.add_box),
              label: 'Add Course',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showLogoutDialog(context, bgColor, appBarColor, textColor, hintColor);
        },
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.logout),
        label: const Text("Logout"),
        tooltip: 'Logout',
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, Color bgColor, Color appBarColor,
      Color textColor, Color hintColor) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: appBarColor,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Logout",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Text(
            "Are you sure you want to logout from your account?",
            style: TextStyle(
              color: hintColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: hintColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}