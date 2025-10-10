// lib/screens/teacher/add_course_content_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'document_viewer_page.dart';


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

  // Content type selection
  String _contentType = 'VIDEO'; // VIDEO, PDF, PPT, DOC

  // Video files
  File? _selectedVideo;
  File? _selectedThumbnail;
  String? _selectedVideoName;
  String? _selectedThumbnailName;

  // Document file
  File? _selectedDocument;
  String? _selectedDocumentName;

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

  Future<void> _pickDocument(String type) async {
    FileType fileType;
    List<String> allowedExtensions;

    switch (type) {
      case 'PDF':
        fileType = FileType.custom;
        allowedExtensions = ['pdf'];
        break;
      case 'PPT':
        fileType = FileType.custom;
        allowedExtensions = ['ppt', 'pptx'];
        break;
      case 'DOC':
        fileType = FileType.custom;
        allowedExtensions = ['doc', 'docx'];
        break;
      default:
        return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: fileType,
      allowedExtensions: allowedExtensions,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedDocument = File(result.files.single.path!);
        _selectedDocumentName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadAndSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate based on content type
    if (_contentType == 'VIDEO' && _selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a video to upload")),
      );
      return;
    }

    if (_contentType != 'VIDEO' && _selectedDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a $_contentType file to upload")),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final uploadResponse = await ApiService.uploadCourseFile(
        _contentType == 'VIDEO' ? _selectedVideo! : _selectedDocument!,
        thumbnail: _contentType == 'VIDEO' ? _selectedThumbnail : null,
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

  void _clearSelection() {
    setState(() {
      _selectedVideo = null;
      _selectedVideoName = null;
      _selectedThumbnail = null;
      _selectedThumbnailName = null;
      _selectedDocument = null;
      _selectedDocumentName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Course Content"),
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
                          "Add new content to this course",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Content Type Selection
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Content Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildContentTypeChip('VIDEO', Icons.video_library, Colors.blue),
                            _buildContentTypeChip('PDF', Icons.picture_as_pdf, Colors.red),
                            _buildContentTypeChip('PPT', Icons.slideshow, Colors.orange),
                            _buildContentTypeChip('DOC', Icons.description, Colors.indigo),
                          ],
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
                        const Text("Content Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: "Content Title",
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.title, color: Colors.blueAccent),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "e.g., Introduction to Course",
                          ),
                          validator: (value) => value?.isEmpty == true ? "Enter content title" : null,
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

                // Upload Section - Video
                if (_contentType == 'VIDEO') _buildVideoUploadSection(),

                // Upload Section - Documents
                if (_contentType != 'VIDEO') _buildDocumentUploadSection(),

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadAndSubmit,
                  icon: _isUploading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : const Icon(Icons.cloud_upload),
                  label: Text(
                    _isUploading ? "Uploading..." : "Upload Content",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                if (_isUploading)
                  Card(
                    margin: const EdgeInsets.only(top: 16),
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _contentType == 'VIDEO'
                                      ? "Uploading to YouTube..."
                                      : "Uploading to server...",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Please wait, this may take a few minutes",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
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

  Widget _buildContentTypeChip(String type, IconData icon, Color color) {
    final isSelected = _contentType == type;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(type),
        ],
      ),
      onSelected: _isUploading ? null : (selected) {
        if (selected) {
          setState(() {
            _contentType = type;
            _clearSelection();
          });
        }
      },
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildVideoUploadSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.video_library, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text("Upload Video", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickVideo,
              icon: const Icon(Icons.video_file),
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
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.image, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text("Thumbnail (Optional)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickThumbnail,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(
                _selectedThumbnail == null
                    ? "Select Thumbnail"
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
    );
  }

  Widget _buildDocumentUploadSection() {
    Color typeColor;
    IconData typeIcon;
    String fileTypeText;

    switch (_contentType) {
      case 'PDF':
        typeColor = Colors.red;
        typeIcon = Icons.picture_as_pdf;
        fileTypeText = 'PDF Document';
        break;
      case 'PPT':
        typeColor = Colors.orange;
        typeIcon = Icons.slideshow;
        fileTypeText = 'PowerPoint Presentation';
        break;
      case 'DOC':
        typeColor = Colors.indigo;
        typeIcon = Icons.description;
        fileTypeText = 'Word Document';
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.insert_drive_file;
        fileTypeText = 'Document';
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(typeIcon, color: typeColor),
                const SizedBox(width: 8),
                Text("Upload $fileTypeText", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : () => _pickDocument(_contentType),
              icon: Icon(typeIcon),
              label: Text(
                _selectedDocument == null
                    ? "Select $_contentType File"
                    : _selectedDocumentName ?? "$_contentType selected",
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: typeColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            if (_selectedDocument != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: typeColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: typeColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedDocumentName ?? "$_contentType selected",
                            style: TextStyle(
                              color: typeColor.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Ready to upload",
                            style: TextStyle(
                              color: typeColor.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "This file will be uploaded to the server and accessible to students",
                      style: TextStyle(color: Colors.blue[900], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
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