import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

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

  List<Widget> get _pages => const [
    MyCoursesPage(),
    UploadContentPage(),
    AssignmentsPage(),
    ReportsPage(),
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
        backgroundColor:
        isDarkMode ? const Color(0xFF1E293B) : Colors.grey[100],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: isDarkMode ? Colors.white70 : Colors.black45,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'My Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
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

/// =======================
/// Teacher Pages
/// =======================

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Card(
          child: ListTile(
            title: Text("Flutter Development"),
            subtitle: Text("30 Students Enrolled"),
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Data Science Basics"),
            subtitle: Text("22 Students Enrolled"),
          ),
        ),
      ],
    );
  }
}

class UploadContentPage extends StatefulWidget {
  const UploadContentPage({super.key});

  @override
  State<UploadContentPage> createState() => _UploadContentPageState();
}

class _UploadContentPageState extends State<UploadContentPage> {
  bool isUploading = false;
  List<Map<String, dynamic>> uploadedFiles = [];
  bool isLoadingFiles = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => isLoadingFiles = true);
    try {
      final files = await ApiService.fetchUploadedFiles();
      setState(() {
        uploadedFiles = files;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load files: $e")),
      );
    }
    setState(() => isLoadingFiles = false);
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);

    setState(() => isUploading = true);

    try {
      final response = await ApiService.uploadFile(file);

      final msg = response['msg'] ?? "Upload complete";
      final fileUrl = response['data']?['fileUrl'] ?? "No fileUrl returned";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$msg\n$fileUrl")),
      );

      // refresh list after upload
      await _loadFiles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    }

    setState(() => isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: isUploading ? null : _pickAndUploadFile,
          icon: const Icon(Icons.upload_file),
          label: Text(isUploading ? "Uploading..." : "Upload Course File"),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: isLoadingFiles
              ? const Center(child: CircularProgressIndicator())
              : uploadedFiles.isEmpty
              ? const Center(child: Text("No files uploaded yet"))
              : ListView.builder(
            itemCount: uploadedFiles.length,
            itemBuilder: (context, index) {
              final file = uploadedFiles[index];
              final url = file["fileUrl"] ?? "";
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: Text(url.split('/').last),
                  subtitle: Text(url),
                  onTap: () {
                    // TODO: open file viewer later
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


class AssignmentsPage extends StatelessWidget {
  const AssignmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Card(
          child: ListTile(
            title: Text("Assignment 1"),
            subtitle: Text("Due: 2025-10-20"),
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Assignment 2"),
            subtitle: Text("Due: 2025-10-30"),
          ),
        ),
      ],
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Reports and Analytics will be shown here"),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Settings Page"),
    );
  }
}
