// lib/screens/teacher/my_courses_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'course_content_page.dart';

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
    final priceController =
    TextEditingController(text: course["price"]?.toString() ?? "0");

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

  void _viewCourseContent(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseContentPage(course: course),
      ),
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
              child: Text("Failed to load courses:\n${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No courses found. Add a course to get started."),
            );
          }
          final courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.menu_book, size: 40),
                  title: Text(
                    course["title"] ?? "Untitled",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(course["description"] ?? "No description"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₹${course["price"] ?? 0}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _editCourse(course),
                      ),
                    ],
                  ),
                  onTap: () => _viewCourseContent(course),
                ),
              );
            },
          );
        },
      ),
    );
  }
}