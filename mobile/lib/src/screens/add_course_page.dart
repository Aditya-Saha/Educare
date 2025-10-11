import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'course_content_page.dart';

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
  bool _isPublished = false;

  Future<void> _submitCourse() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;

    setState(() => _isLoading = true);
    try {
      final course = await ApiService.addCourse(
        title,
        desc,
        price,
        published: _isPublished,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "✅ Course added: ${course['title']} (${_isPublished ? 'Published' : 'Draft'})",
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      _clearForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to add course: $e"),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  void _clearForm() {
    _titleController.clear();
    _descController.clear();
    _priceController.clear();
    setState(() => _isPublished = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF030303);
    final hintColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF606060);
    final borderColor = isDark ? const Color(0xFF313131) : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        title: Text(
          "Create New Course",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Course Title Field
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    style: TextStyle(color: textColor, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Course Title",
                      labelStyle: TextStyle(
                        color: hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                      hintStyle: TextStyle(color: hintColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: Icon(Icons.book, color: hintColor),
                    ),
                    validator: (value) =>
                    value?.isEmpty == true ? "Enter a course title" : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Description Field
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    style: TextStyle(color: textColor, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Course Description",
                      labelStyle: TextStyle(
                        color: hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                      hintStyle: TextStyle(color: hintColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(Icons.description, color: hintColor),
                      ),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) =>
                    value?.isEmpty == true
                        ? "Enter a course description"
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Price Field
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: textColor, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Course Price",
                      labelStyle: TextStyle(
                        color: hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: "₹ 0",
                      hintStyle: TextStyle(color: hintColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: Icon(Icons.currency_rupee, color: hintColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter course price";
                      }
                      if (int.tryParse(value) == null) {
                        return "Enter a valid number";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Published Toggle
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isPublished
                          ? Colors.blue.shade600
                          : borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isPublished ? Icons.check_circle : Icons.visibility,
                              color: _isPublished
                                  ? Colors.blue.shade600
                                  : hintColor,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Publish Course",
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _isPublished
                                      ? "✓ Will be visible to students"
                                      : "○ Will remain as draft",
                                  style: TextStyle(
                                    color: _isPublished
                                        ? Colors.blue.shade600
                                        : hintColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _isPublished,
                          onChanged: (value) {
                            setState(() => _isPublished = value);
                          },
                          activeColor: Colors.blue.shade600,
                          inactiveThumbColor: hintColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitCourse,
                    icon: _isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Icon(Icons.add, size: 22),
                    label: Text(
                      _isLoading ? "Adding Course..." : "Add Course",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Info text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.blue.shade900.withOpacity(0.3)
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Published courses appear on dashboard. Draft courses are saved privately.",
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}