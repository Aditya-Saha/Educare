import 'package:flutter/material.dart';
import 'notes_section.dart';

/// Standalone Notes Page
/// Can be used to view all course notes or notes for a specific content
class NotesPage extends StatelessWidget {
  final int courseId;
  final int? contentId;
  final String courseTitle;
  final String? contentTitle; // Optional: specific content title

  const NotesPage({
    super.key,
    required this.courseId,
    this.contentId,
    required this.courseTitle,
    this.contentTitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final textColor = isDark ? Colors.white : const Color(0xFF030303);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contentTitle ?? "Notes",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              courseTitle,
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          // Filter button (optional - can be used to filter by current user)
          IconButton(
            icon: Icon(Icons.filter_list, color: textColor),
            tooltip: "Filter notes",
            onPressed: () {
              _showFilterDialog(context, isDark);
            },
          ),
          // Info button
          IconButton(
            icon: Icon(Icons.info_outline, color: textColor),
            tooltip: "About notes",
            onPressed: () {
              _showInfoDialog(context, isDark);
            },
          ),
        ],
      ),
      body: NotesSection(
        courseId: courseId,
        contentId: contentId,
      ),
    );
  }

  void _showInfoDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: Colors.blue.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              "About Notes",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Take notes while learning and engage with your peers.",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                Icons.add_circle_outline,
                "Add notes for the entire course or specific content",
                isDark,
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                Icons.reply,
                "Reply to notes from other students",
                isDark,
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                Icons.edit,
                "Edit or delete your own notes anytime",
                isDark,
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                Icons.forum,
                "View all course discussions in one place",
                isDark,
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                Icons.refresh,
                "Pull down to refresh the notes list",
                isDark,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue.shade600,
            ),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          "Filter Options",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inbox),
              title: Text(
                "All Notes",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implement filter logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                "My Notes",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implement filter logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.reply),
              title: Text(
                "Notes with Replies",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implement filter logic
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blue.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget to show note count badge (can be used in content list)
class NoteCountBadge extends StatelessWidget {
  final int noteCount;
  final VoidCallback? onTap;
  final bool showIcon;

  const NoteCountBadge({
    super.key,
    required this.noteCount,
    this.onTap,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    if (noteCount == 0) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF252525)
              : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.shade600.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                Icons.comment,
                size: 14,
                color: Colors.blue.shade600,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              noteCount > 99 ? '99+' : noteCount.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating Action Button for quick note access
class QuickNoteFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final int? unreadCount;

  const QuickNoteFAB({
    super.key,
    required this.onPressed,
    this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: Colors.blue.shade600,
          child: const Icon(Icons.note_add, color: Colors.white),
        ),
        if (unreadCount != null && unreadCount! > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                unreadCount! > 9 ? '9+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// Helper widget to navigate to notes page
class NotesNavigationHelper {
  /// Navigate to notes page for a course
  static void navigateToNotes({
    required BuildContext context,
    required int courseId,
    required String courseTitle,
    int? contentId,
    String? contentTitle,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotesPage(
          courseId: courseId,
          contentId: contentId,
          courseTitle: courseTitle,
          contentTitle: contentTitle,
        ),
      ),
    );
  }
}