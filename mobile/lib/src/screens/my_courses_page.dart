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
  String _filterStatus = "All";

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

  List<Map<String, dynamic>> _filterCourses(List<Map<String, dynamic>> courses) {
    if (_filterStatus == "All") return courses;
    return courses.where((course) {
      bool isPublished = course["published"] ?? false;
      if (_filterStatus == "Published") return isPublished;
      if (_filterStatus == "Draft") return !isPublished;
      return true;
    }).toList();
  }

  void _editCourse(Map<String, dynamic> course) {
    final titleController = TextEditingController(text: course["title"]);
    final descController = TextEditingController(text: course["description"]);
    final priceController =
    TextEditingController(text: course["price"]?.toString() ?? "0");
    bool isPublished = course["published"] ?? false;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF030303);
    final hintColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF606060);
    final borderColor = isDark ? const Color(0xFF313131) : const Color(0xFFE0E0E0);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                "Edit Course",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: TextField(
                        controller: titleController,
                        style: TextStyle(color: textColor, fontSize: 15),
                        decoration: InputDecoration(
                          labelText: "Course Title",
                          labelStyle: TextStyle(
                              color: hintColor, fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          prefixIcon:
                          Icon(Icons.book, color: hintColor, size: 20),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: TextField(
                        controller: descController,
                        maxLines: 3,
                        style: TextStyle(color: textColor, fontSize: 15),
                        decoration: InputDecoration(
                          labelText: "Description",
                          labelStyle: TextStyle(
                              color: hintColor, fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(Icons.description, color: hintColor, size: 20),
                          ),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor, fontSize: 15),
                        decoration: InputDecoration(
                          labelText: "Price",
                          labelStyle: TextStyle(
                              color: hintColor, fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          prefixIcon: Icon(Icons.currency_rupee,
                              color: hintColor, size: 20),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                          isPublished ? Colors.blue.shade600 : borderColor,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isPublished
                                      ? Icons.check_circle
                                      : Icons.visibility,
                                  color: isPublished
                                      ? Colors.blue.shade600
                                      : hintColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Publish",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      isPublished ? "Published" : "Draft",
                                      style: TextStyle(
                                        color: isPublished
                                            ? Colors.green.shade600
                                            : hintColor,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              value: isPublished,
                              onChanged: (value) {
                                setState(() => isPublished = value);
                              },
                              activeColor: Colors.blue.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: hintColor, fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () async {
                    try {
                      await ApiService.updateCourse(
                        course["id"],
                        titleController.text.trim(),
                        descController.text.trim(),
                        int.tryParse(priceController.text.trim()) ?? 0,
                        published: isPublished,
                      );
                      if (!mounted) return;
                      Navigator.pop(context);
                      _refreshCourses();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          const Text("✅ Course updated successfully"),
                          backgroundColor: Colors.green.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("❌ Failed to update: $e"),
                          backgroundColor: Colors.red.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ],
            );
          },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF030303);
    final hintColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF606060);

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: _refreshCourses,
        color: Colors.blue.shade600,
        backgroundColor: cardColor,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _coursesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue.shade600,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: hintColor),
                    const SizedBox(height: 16),
                    Text(
                      "Failed to load courses",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_outline, size: 64, color: hintColor),
                    const SizedBox(height: 16),
                    Text(
                      "No courses yet",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            final allCourses = snapshot.data!;
            final filteredCourses = _filterCourses(allCourses);

            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: ["All", "Published", "Draft"].map((status) {
                        bool isSelected = _filterStatus == status;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() => _filterStatus = status);
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.shade600
                                      : cardColor,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue.shade600
                                        : hintColor,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : textColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredCourses.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 48, color: hintColor),
                        const SizedBox(height: 12),
                        Text(
                          "No $_filterStatus courses",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      final isPublished = course["published"] ?? false;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF313131)
                                : const Color(0xFFE0E0E0),
                            width: 0.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () =>
                                _viewCourseContent(course),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 75,
                                        height: 75,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.blue.shade400,
                                              Colors.blue.shade700,
                                            ],
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.menu_book_rounded,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                      Positioned(
                                        top: -5,
                                        right: -5,
                                        child: Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isPublished
                                                ? Colors.green.shade600
                                                : Colors.orange.shade600,
                                            borderRadius:
                                            BorderRadius.circular(12),
                                            border: Border.all(
                                              color: cardColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            isPublished
                                                ? "Published"
                                                : "Draft",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          course["title"] ?? "Untitled",
                                          maxLines: 2,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight:
                                            FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          course["description"] ??
                                              "No description",
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: hintColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              "₹${course["price"] ?? 0}",
                                              style: TextStyle(
                                                color: Colors
                                                    .green.shade600,
                                                fontWeight:
                                                FontWeight.w700,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              padding:
                                              const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 8,
                                                  vertical: 3),
                                              decoration:
                                              BoxDecoration(
                                                color: isPublished
                                                    ? Colors
                                                    .green.shade100
                                                    : Colors
                                                    .orange.shade100,
                                                borderRadius:
                                                BorderRadius
                                                    .circular(6),
                                              ),
                                              child: Text(
                                                isPublished
                                                    ? "✓ Live"
                                                    : "○ Draft",
                                                style: TextStyle(
                                                  color: isPublished
                                                      ? Colors.green
                                                      .shade700
                                                      : Colors.orange
                                                      .shade700,
                                                  fontSize: 12,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit_rounded,
                                          color:
                                          Colors.blue.shade600,
                                          size: 22,
                                        ),
                                        onPressed: () =>
                                            _editCourse(course),
                                        padding: EdgeInsets.zero,
                                        constraints:
                                        const BoxConstraints(
                                            minWidth: 40,
                                            minHeight: 40),
                                      ),
                                      Icon(
                                        Icons
                                            .arrow_forward_ios_rounded,
                                        color: hintColor,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}