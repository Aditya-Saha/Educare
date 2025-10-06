// lib/screens/teacher/course_content_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_course_content_page.dart';
import 'custom_video_player_page.dart';

class CourseContentPage extends StatefulWidget {
  final Map<String, dynamic> course;
  const CourseContentPage({super.key, required this.course});

  @override
  State<CourseContentPage> createState() => _CourseContentPageState();
}

class _CourseContentPageState extends State<CourseContentPage> {
  late Future<List<Map<String, dynamic>>> _contentFuture;

  @override
  void initState() {
    super.initState();
    _loadContent();
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
      return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
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
        const SnackBar(content: Text("Invalid video URL")),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course["title"] ?? "Course Content"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addContent,
            tooltip: "Add Content",
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Failed to load content:\n${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.video_library_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No videos added yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addContent,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Content"),
                  ),
                ],
              ),
            );
          }
          final contents = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contents.length,
            itemBuilder: (context, index) {
              final content = contents[index];
              final fileType = content["fileType"] ?? "VIDEO";
              final url = content["fileUrl"] ?? "";
              final title = content["title"] ?? "Untitled";
              final isFree = content["isFree"] ?? false;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (fileType.toUpperCase() == "VIDEO")
                      GestureDetector(
                        onTap: () => _playVideo(url),
                        child: Stack(
                          children: [
                            Image.network(
                              _getYouTubeThumbnail(url),
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.video_library, size: 60),
                                );
                              },
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(_getFileIcon(fileType), color: Colors.blueAccent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(
                                  isFree ? "FREE" : "PAID",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: isFree ? Colors.green : Colors.orange,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            fileType.toUpperCase(),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          if (content["durationSeconds"] != null)
                            Text(
                              "Duration: ${content["durationSeconds"]} seconds",
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContent,
        child: const Icon(Icons.add),
        tooltip: "Add Content",
      ),
    );
  }
}