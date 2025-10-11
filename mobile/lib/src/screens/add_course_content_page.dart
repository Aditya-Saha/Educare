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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF212121);
    final hintColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF757575);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Add Course Content",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Course Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Course: ${widget.course["title"]}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Add new content to this course",
                      style: TextStyle(color: hintColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Content Type Selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Content Type",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildContentTypeChip('VIDEO', Icons.video_library, Colors.blue, isDark),
                        _buildContentTypeChip('PDF', Icons.picture_as_pdf, Colors.red, isDark),
                        _buildContentTypeChip('PPT', Icons.slideshow, Colors.orange, isDark),
                        _buildContentTypeChip('DOC', Icons.description, Colors.indigo, isDark),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Content Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Content Details",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Content Title",
                        labelStyle: TextStyle(color: hintColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                        ),
                        prefixIcon: Icon(Icons.title, color: Colors.blue.shade600),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF252525) : const Color(0xFFFAFAFA),
                        hintText: "e.g., Introduction to Course",
                        hintStyle: TextStyle(color: hintColor.withOpacity(0.6)),
                      ),
                      validator: (value) => value?.isEmpty == true ? "Enter content title" : null,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Free Content",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      subtitle: Text(
                        _isFree ? "Available to all students" : "Requires course purchase",
                        style: TextStyle(color: hintColor, fontSize: 12),
                      ),
                      value: _isFree,
                      onChanged: (value) => setState(() => _isFree = value),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Upload Section - Video
              if (_contentType == 'VIDEO') _buildVideoUploadSection(isDark, cardColor, textColor, hintColor),

              // Upload Section - Documents
              if (_contentType != 'VIDEO') _buildDocumentUploadSection(isDark, cardColor, textColor, hintColor),

              const SizedBox(height: 20),

              // Upload Button
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),

              if (_isUploading) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _contentType == 'VIDEO'
                                  ? "Uploading to YouTube..."
                                  : "Uploading to server...",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Please wait, this may take a few minutes",
                              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentTypeChip(String type, IconData icon, Color color, bool isDark) {
    final isSelected = _contentType == type;
    return ChoiceChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : color),
          const SizedBox(width: 6),
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
      backgroundColor: isDark ? const Color(0xFF252525) : const Color(0xFFF0F0F0),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? color : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
        ),
      ),
    );
  }

  Widget _buildVideoUploadSection(bool isDark, Color cardColor, Color textColor, Color hintColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.video_library, color: Colors.blue.shade600, size: 22),
              const SizedBox(width: 8),
              Text(
                "Upload Video",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _pickVideo,
            icon: const Icon(Icons.video_file, size: 20),
            label: Text(
              _selectedVideo == null ? "Select Video" : _selectedVideoName ?? "Video selected",
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (_selectedVideo != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedVideoName ?? "Video selected",
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Divider(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.image, color: Colors.orange.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                "Thumbnail (Optional)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _pickThumbnail,
            icon: const Icon(Icons.add_photo_alternate, size: 20),
            label: Text(
              _selectedThumbnail == null
                  ? "Select Thumbnail"
                  : _selectedThumbnailName ?? "Thumbnail selected",
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (_selectedThumbnail != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedThumbnailName ?? "Thumbnail selected",
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentUploadSection(bool isDark, Color cardColor, Color textColor, Color hintColor) {
    Color typeColor;
    IconData typeIcon;
    String fileTypeText;

    switch (_contentType) {
      case 'PDF':
        typeColor = Colors.red.shade600;
        typeIcon = Icons.picture_as_pdf;
        fileTypeText = 'PDF Document';
        break;
      case 'PPT':
        typeColor = Colors.orange.shade600;
        typeIcon = Icons.slideshow;
        fileTypeText = 'PowerPoint';
        break;
      case 'DOC':
        typeColor = Colors.indigo.shade600;
        typeIcon = Icons.description;
        fileTypeText = 'Word Document';
        break;
      default:
        typeColor = Colors.grey.shade600;
        typeIcon = Icons.insert_drive_file;
        fileTypeText = 'Document';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(typeIcon, color: typeColor, size: 22),
              const SizedBox(width: 8),
              Text(
                "Upload $fileTypeText",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isUploading ? null : () => _pickDocument(_contentType),
            icon: Icon(typeIcon, size: 20),
            label: Text(
              _selectedDocument == null
                  ? "Select $_contentType File"
                  : _selectedDocumentName ?? "$_contentType selected",
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: typeColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (_selectedDocument != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: typeColor.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: typeColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDocumentName ?? "$_contentType selected",
                          style: TextStyle(
                            color: isDark ? Colors.white : typeColor.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Ready to upload",
                          style: TextStyle(
                            color: isDark ? hintColor : typeColor.withOpacity(0.7),
                            fontSize: 11,
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
              color: Colors.blue.shade50.withOpacity(isDark ? 0.2 : 1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.shade300.withOpacity(isDark ? 0.3 : 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "This file will be uploaded and accessible to students",
                    style: TextStyle(
                      color: isDark ? Colors.blue.shade200 : Colors.blue.shade900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}