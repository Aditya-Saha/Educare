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

  // Pages
  final List<Widget> _pages = const [
    MyCoursesPage(),
    AddCoursePage(),
    UploadContentPage(),
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
            icon: Icon(Icons.add_box_outlined),
            label: 'Add Course',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Upload Content',
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

//
// =======================
// Teacher Pages
// =======================
//

/// My Courses Page
class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  late Future<List<Map<String, dynamic>>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = ApiService.fetchCourses();
  }

  Future<void> _refreshCourses() async {
    setState(() {
      _coursesFuture = ApiService.fetchCourses();
    });
  }

  void _editCourse(Map<String, dynamic> course) {
    final titleController = TextEditingController(text: course["title"]);
    final descController = TextEditingController(text: course["description"]);
    final priceController = TextEditingController(text: course["price"]?.toString() ?? "0");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Course"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () async {
                try {
                  await ApiService.updateCourse(
                    course["id"],
                    titleController.text.trim(),
                    descController.text.trim(),
                    int.tryParse(priceController.text.trim()) ?? 0,
                  );
                  if (!mounted) return;
                  Navigator.pop(context);
                  _refreshCourses();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ Course updated")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ Failed to update: $e")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshCourses,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("❌ Failed to load courses:\n${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("📭 No courses found. Add a course to get started."),
            );
          }

          final courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text(course["title"] ?? "Untitled"),
                  subtitle: Text(course["description"] ?? "No description"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("₹${course["price"] ?? 0}"),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _editCourse(course),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
/// Add Course Page
class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitCourse() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;

    setState(() => _isLoading = true);

    try {
      final course = await ApiService.addCourse(title, desc, price);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Course added: ${course['title']}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to add course: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Course Title",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price (₹)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter price";
                  if (int.tryParse(value) == null) return "Enter valid number";
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitCourse,
                icon: const Icon(Icons.add),
                label: Text(_isLoading ? "Adding..." : "Add Course"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Upload Content Page
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

/// Settings Page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Settings Page"),
    );
  }
}
