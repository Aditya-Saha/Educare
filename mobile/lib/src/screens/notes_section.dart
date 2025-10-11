import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotesSection extends StatefulWidget {
  final int courseId;
  final int? contentId;

  const NotesSection({
    super.key,
    required this.courseId,
    this.contentId,
  });

  @override
  State<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  final TextEditingController _noteController = TextEditingController();
  final Map<int, TextEditingController> _replyControllers = {};
  final Map<int, TextEditingController> _editControllers = {};
  final Map<int, bool> _showReplyBox = {};
  final Map<int, bool> _editingNote = {};
  final Map<int, bool> _isUpdating = {};
  final Map<int, bool> _isDeleting = {};

  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  int? _currentUserId;
  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _loadNotes();
  }
  Future<void> _loadCurrentUserId() async {
    try {
      // TODO: Replace with your actual user ID retrieval
      // Example: final userId = await ApiService.getCurrentUserId();
      _currentUserId = await _getCurrentUserIdFromStorage();
    } catch (e) {
      print("❌ Error loading current user ID: $e");
      _currentUserId = null;
    }
  }

  Future<int?> _getCurrentUserIdFromStorage() async {
    // TODO: Implement based on your auth system
    // For now, this returns null
    return null;
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print("🔵 Loading notes for courseId: ${widget.courseId}");
      final notes = await ApiService.fetchCourseNotes(widget.courseId);

      if (mounted) {
        final transformedNotes = notes.map((note) {
          final replies = (note['replies'] as List<dynamic>?)?.map((reply) {
            return {
              'id': reply['id'],
              'noteText': reply['content'] ?? '',
              'authorName': reply['userName'] ?? 'Anonymous',
              'createdAt': reply['createdAt'],
              'isCurrentUser': false, // Set to false for testing
              'parentNoteId': note['id'],
            };
          }).toList() ?? [];

          return {
            'id': note['id'],
            'noteText': note['content'] ?? note['title'] ?? '',
            'authorName': note['userName'] ?? 'Anonymous',
            'createdAt': note['createdAt'],
            'isCurrentUser': false, // Set to false for testing
            'parentNoteId': note['parentNoteId'],
            'replies': replies,
          };
        }).toList();

        setState(() {
          _notes = transformedNotes;
          _isLoading = false;
        });
        print("✅ Notes loaded successfully: ${transformedNotes.length} notes");
      }
    } catch (e) {
      print("❌ Error loading notes: $e");
      if (mounted) {
        setState(() {
          _notes = [];
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _addNote() async {
    final noteText = _noteController.text.trim();

    if (noteText.isEmpty) {
      _showSnackBar("Please enter a note", isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      print("🔵 Adding note: $noteText");
      print("🔵 CourseId: ${widget.courseId}, ContentId: ${widget.contentId}");

      await ApiService.addNote(
        courseId: widget.courseId,
        contentId: widget.contentId,
        noteText: noteText,
      );

      _noteController.clear();

      print("✅ Note added successfully");
      _showSnackBar("Note added successfully", isError: false);

      // Reload notes after adding
      await _loadNotes();

    } catch (e) {
      print("❌ Error adding note: $e");
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _updateNote(int noteId, String text, int? parentNoteId) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      _showSnackBar("Note cannot be empty", isError: true);
      return;
    }

    setState(() => _isUpdating[noteId] = true);

    try {
      print("🔵 Updating note $noteId: $trimmedText");

      await ApiService.updateNote(
        noteId: noteId,
        courseId: widget.courseId,
        contentId: widget.contentId,
        parentNoteId: parentNoteId,
        noteText: trimmedText,
      );

      setState(() {
        _editingNote[noteId] = false;
        _isUpdating[noteId] = false;
      });

      print("✅ Note updated successfully");
      _showSnackBar("Note updated successfully", isError: false);

      // Reload notes after updating
      await _loadNotes();

    } catch (e) {
      print("❌ Error updating note: $e");
      setState(() => _isUpdating[noteId] = false);
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  Future<void> _deleteNote(int noteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          title: Text(
            "Delete Note",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this note? This action cannot be undone.",
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isDeleting[noteId] = true);

    try {
      print("🔵 Deleting note $noteId");

      await ApiService.deleteNote(
        noteId: noteId,
        courseId: widget.courseId,
      );

      setState(() => _isDeleting[noteId] = false);

      print("✅ Note deleted successfully");
      _showSnackBar("Note deleted successfully", isError: false);

      // Reload notes after deleting
      await _loadNotes();

    } catch (e) {
      print("❌ Error deleting note: $e");
      setState(() => _isDeleting[noteId] = false);
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  Future<void> _addReply(int parentNoteId) async {
    final controller = _replyControllers[parentNoteId];
    if (controller == null || controller.text.trim().isEmpty) {
      _showSnackBar("Please enter a reply", isError: true);
      return;
    }

    final replyText = controller.text.trim();

    try {
      print("🔵 Adding reply to note $parentNoteId: $replyText");

      await ApiService.addNote(
        courseId: widget.courseId,
        contentId: widget.contentId,
        noteText: replyText,
        parentNoteId: parentNoteId,
      );

      controller.clear();
      setState(() => _showReplyBox[parentNoteId] = false);

      print("✅ Reply added successfully");
      _showSnackBar("Reply added successfully", isError: false);

      // Reload notes after adding reply
      await _loadNotes();

    } catch (e) {
      print("❌ Error adding reply: $e");
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return "Just now";

    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 365) {
        return "${diff.inDays ~/ 365} year${diff.inDays ~/ 365 > 1 ? 's' : ''} ago";
      } else if (diff.inDays > 30) {
        return "${diff.inDays ~/ 30} month${diff.inDays ~/ 30 > 1 ? 's' : ''} ago";
      } else if (diff.inDays > 0) {
        return "${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago";
      } else if (diff.inHours > 0) {
        return "${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago";
      } else if (diff.inMinutes > 0) {
        return "${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      return "Just now";
    }
  }

  Widget _buildNoteItem(Map<String, dynamic> note, bool isReply, {int level = 0}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF030303);
    final hintColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF606060);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final noteId = note["id"] as int;
    final authorName = note["authorName"] ?? "Anonymous";
    final noteText = note["noteText"] ?? "";
    final timestamp = note["createdAt"];
    final isCurrentUser = note["isCurrentUser"] ?? false;
    final parentNoteId = note["parentNoteId"] as int?;
    final replies = (note["replies"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    // Initialize edit controller if not exists
    if (!_editControllers.containsKey(noteId)) {
      _editControllers[noteId] = TextEditingController(text: noteText);
    }

    final editController = _editControllers[noteId]!;
    final isEditing = _editingNote[noteId] ?? false;
    final isUpdating = _isUpdating[noteId] ?? false;
    final isDeleting = _isDeleting[noteId] ?? false;

    return Opacity(
      opacity: isDeleting ? 0.5 : 1.0,
      child: Container(
        margin: EdgeInsets.only(
          left: level > 0 ? 40.0 : 0,
          bottom: 12,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isReply
              ? (isDark ? const Color(0xFF252525) : const Color(0xFFF5F5F5))
              : cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author and timestamp
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.shade600,
                  child: Text(
                    authorName.isNotEmpty ? authorName[0].toUpperCase() : "?",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            authorName,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade600.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "You",
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(
                          color: hintColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrentUser && !isEditing && !isDeleting)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 18, color: hintColor),
                    onSelected: (value) {
                      if (value == 'edit') {
                        setState(() {
                          _editingNote[noteId] = true;
                          editController.text = noteText;
                        });
                      } else if (value == 'delete') {
                        _deleteNote(noteId);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Note text or edit field
            if (isEditing)
              Column(
                children: [
                  TextField(
                    controller: editController,
                    maxLines: null,
                    autofocus: true,
                    style: TextStyle(color: textColor, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Edit your note...",
                      hintStyle: TextStyle(color: hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: hintColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: hintColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isUpdating ? null : () {
                          setState(() {
                            _editingNote[noteId] = false;
                            editController.text = noteText;
                          });
                        },
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isUpdating
                            ? null
                            : () => _updateNote(noteId, editController.text, parentNoteId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          disabledBackgroundColor: Colors.blue.shade300,
                        ),
                        child: isUpdating
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text("Update"),
                      ),
                    ],
                  ),
                ],
              )
            else
              Text(
                noteText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

            if (!isEditing && !isDeleting) ...[
              const SizedBox(height: 10),
              // Reply button
              InkWell(
                onTap: () {
                  setState(() {
                    _showReplyBox[noteId] = !(_showReplyBox[noteId] ?? false);
                    if (_showReplyBox[noteId] == true && !_replyControllers.containsKey(noteId)) {
                      _replyControllers[noteId] = TextEditingController();
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.reply, size: 16, color: hintColor),
                      const SizedBox(width: 4),
                      Text(
                        "Reply",
                        style: TextStyle(
                          color: hintColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (replies.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Text(
                          "${replies.length} ${replies.length == 1 ? 'reply' : 'replies'}",
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // Reply input box
            if (_showReplyBox[noteId] == true) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyControllers[noteId],
                      maxLines: null,
                      style: TextStyle(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Add a reply...",
                        hintStyle: TextStyle(color: hintColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: hintColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: hintColor.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _addReply(noteId),
                    icon: const Icon(Icons.send),
                    color: Colors.blue.shade600,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade600.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ],

            // Replies
            if (replies.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...replies.map((reply) => _buildNoteItem(reply, true, level: level + 1)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF030303);
    final hintColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF606060);
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);

    return Container(
      color: bgColor,
      child: Column(
        children: [
          // Add note input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFE5E5E5),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Notes",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _noteController,
                        maxLines: null,
                        enabled: !_isSubmitting,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: "Add a note...",
                          hintStyle: TextStyle(color: hintColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: hintColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: hintColor.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _addNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.blue.shade300,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(Icons.send, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notes list
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue.shade600,
              ),
            )
                : _errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: hintColor),
                  const SizedBox(height: 16),
                  Text(
                    "Failed to load notes",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: hintColor, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadNotes,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
                : _notes.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_outlined, size: 80, color: hintColor),
                  const SizedBox(height: 16),
                  Text(
                    "No notes yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Be the first to add a note!",
                    style: TextStyle(fontSize: 14, color: hintColor),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadNotes,
              color: Colors.blue.shade600,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return _buildNoteItem(_notes[index], false);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    for (var controller in _editControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}