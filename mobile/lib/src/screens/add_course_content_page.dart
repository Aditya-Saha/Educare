// lib/screens/teacher/add_course_content_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class AddCourseContentPage extends StatefulWidget {
  final Map<String, dynamic> course;
  const AddCourseContentPage({super.key, required this.course});

  @override
  State<AddCourseContentPage> createState() => _AddCourseContentPageState();
}

class _AddCourseContentPageState extends State<AddCourseContentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool _isUploading = false;
  bool _isFree = false;
  File? _selectedVideo;
  File? _selectedThumbnail;
  String? _selectedVideoName;
  String? _selectedThumbnailName;

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedVideo = File(result.files.single.path!);
        _selectedVideoName = result.files.single.name;
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedThumbnail = File(result.files.single.path!);
        _selectedThumbnailName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadAndSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a video to upload")),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final uploadResponse = await ApiService.uploadCourseFile(
        _selectedVideo!,
        thumbnail: _selectedThumbnail,
      );
      if (uploadResponse["status"] == "ok") {
        final fileUrl = uploadResponse["data"]["url"];
        final fileType = uploadResponse["data"]["fileType"];
        await ApiService.addCourseContent(
          courseId: widget.course["id"],
          title: _titleController.text.trim(),
          fileType: fileType,
          fileUrl: fileUrl,
          isFree: _isFree,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Content added successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception(uploadResponse["msg"] ?? "Upload failed");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add content: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Video Content"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Course: ${widget.course["title"]}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Add new video to this course",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Video Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: "Video Title",
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.title, color: Colors.blueAccent),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "e.g., Introduction to Course",
                          ),
                          validator: (value) => value?.isEmpty == true ? "Enter video title" : null,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text("Free Content", style: TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            _isFree ? "Available to all students" : "Requires course purchase",
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          value: _isFree,
                          onChanged: (value) => setState(() => _isFree = value),
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Upload Files", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickVideo,
                          icon: const Icon(Icons.video_library),
                          label: Text(
                            _selectedVideo == null ? "Select Video" : _selectedVideoName ?? "Video selected",
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        if (_selectedVideo != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedVideoName ?? "Video selected",
                                    style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickThumbnail,
                          icon: const Icon(Icons.image),
                          label: Text(
                            _selectedThumbnail == null
                                ? "Select Thumbnail (Optional)"
                                : _selectedThumbnailName ?? "Thumbnail selected",
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        if (_selectedThumbnail != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.orange[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedThumbnailName ?? "Thumbnail selected",
                                    style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadAndSubmit,
                  icon: _isUploading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                  )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isUploading ? "Uploading..." : "Upload Video", style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                if (_isUploading)
                  Card(
                    color: Colors.blue[50],
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text("Uploading to server...", style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("Please wait, this may take a few minutes", style: TextStyle(fontSize: 12)),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}