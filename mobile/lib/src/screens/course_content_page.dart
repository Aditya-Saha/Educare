import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_course_content_page.dart';
import 'custom_video_player_page.dart';
import 'document_viewer_page.dart';
import 'notes_section.dart';

class CourseContentPage extends StatefulWidget {
  final Map<String, dynamic> course;
  const CourseContentPage({super.key, required this.course});

  @override
  State<CourseContentPage> createState() => _CourseContentPageState();
}

class _CourseContentPageState extends State<CourseContentPage> with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _contentFuture;
  late TabController _tabController;
  int? _selectedContentId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadContent() {
    setState(() {
      _contentFuture = ApiService.fetchCourseContent(widget.course["id"]);
    });
  }

  void _addContent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCourseContentPage(course: widget.course),
      ),
    ).then((_) => _loadContent());
  }

  String _getYouTubeThumbnail(String url) {
    String? videoId = _extractVideoId(url);
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
    }
    return '';
  }

  String? _extractVideoId(String url) {
    if (url.contains('youtu.be/')) {
      return url.split('youtu.be/').last.split('?').first.split('&').first;
    }
    if (url.contains('youtube.com/watch?v=')) {
      final uri = Uri.parse(url);
      return uri.queryParameters['v'];
    }
    if (url.contains('youtube.com/embed/')) {
      return url.split('youtube.com/embed/').last.split('?').first;
    }
    return null;
  }

  void _playVideo(String url) {
    final videoId = _extractVideoId(url);
    if (videoId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomVideoPlayerPage(videoId: videoId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Invalid video URL"),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _openDocument(String url, String fileType, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerPage(
          url: url,
          fileType: fileType,
          title: title,
        ),
      ),
    );
  }

  void _handleContentTap(String url, String fileType, String title, int contentId) {
    setState(() {
      _selectedContentId = contentId;
    });

    if (fileType.toUpperCase() == 'VIDEO') {
      _playVideo(url);
    } else if (['PDF', 'DOC', 'PPT'].contains(fileType.toUpperCase())) {
      _openDocument(url, fileType, title);
    }

    // Switch to notes tab after selecting content
    _tabController.animateTo(1);
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toUpperCase()) {
      case 'VIDEO':
        return Icons.play_circle_filled;
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'PPT':
        return Icons.slideshow;
      case 'DOC':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String fileType) {
    switch (fileType.toUpperCase()) {
      case 'VIDEO':
        return Colors.red.shade600;
      case 'PDF':
        return Colors.orange.shade600;
      case 'PPT':
        return Colors.blue.shade600;
      case 'DOC':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildContentList(List<Map<String, dynamic>> contents) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF030303);
    final hintColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF606060);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: contents.length,
      itemBuilder: (context, index) {
        final content = contents[index];
        final contentId = content["id"] as int;
        final fileType = content["fileType"] ?? "VIDEO";
        final url = content["fileUrl"] ?? "";
        final title = content["title"] ?? "Untitled";
        final isFree = content["isFree"] ?? false;
        final duration = content["durationSeconds"];
        final isSelected = _selectedContentId == contentId;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleContentTap(url, fileType, title, contentId),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.blue.shade600
                      : (isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFE5E5E5)),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.blue.shade600.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 140,
                      height: 78,
                      color: Colors.black12,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (fileType.toUpperCase() == "VIDEO")
                            Image.network(
                              _getYouTubeThumbnail(url),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.red.shade400,
                                        Colors.red.shade700,
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.video_library,
                                    size: 32,
                                    color: Colors.white70,
                                  ),
                                );
                              },
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _getFileColor(fileType).withOpacity(0.7),
                                    _getFileColor(fileType),
                                  ],
                                ),
                              ),
                              child: Icon(
                                _getFileIcon(fileType),
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                          // Play icon overlay for videos
                          if (fileType.toUpperCase() == "VIDEO")
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          // Duration badge
                          if (duration != null)
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  _formatDuration(duration),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // File type and status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF252525)
                                    : const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getFileIcon(fileType),
                                    size: 11,
                                    color: _getFileColor(fileType),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    fileType.toUpperCase(),
                                    style: TextStyle(
                                      color: hintColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isFree
                                      ? [Colors.green.shade400, Colors.green.shade600]
                                      : [Colors.orange.shade400, Colors.orange.shade600],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isFree ? Colors.green : Colors.orange)
                                        .withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isFree ? Icons.lock_open : Icons.lock,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    isFree ? "FREE" : "PAID",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Selected",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final textColor = isDark ? Colors.white : const Color(0xFF030303);
    final hintColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF606060);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.course["title"] ?? "Course Content",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade600,
          unselectedLabelColor: hintColor,
          indicatorColor: Colors.blue.shade600,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.video_library),
              text: "Content",
            ),
            Tab(
              icon: Icon(Icons.note_alt),
              text: "Notes",
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _contentFuture,
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
                    "Failed to load content",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(color: hintColor, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library_outlined,
                      size: 80, color: hintColor),
                  const SizedBox(height: 16),
                  Text(
                    "No content added yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Add videos, documents, and more",
                    style: TextStyle(fontSize: 14, color: hintColor),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addContent,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Content"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final contents = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: [
              // Content Tab
              _buildContentList(contents),

              // Notes Tab
              NotesSection(
                courseId: widget.course["id"] as int,
                contentId: _selectedContentId,
              ),
            ],
          );
        },
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
        onPressed: _addContent,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Content"),
        elevation: 4,
      )
          : null,
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return "$hours:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
    }
    return "$minutes:${secs.toString().padLeft(2, '0')}";
  }
}