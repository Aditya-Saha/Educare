// lib/src/screens/document_viewer_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentViewerPage extends StatelessWidget {
  final String url;
  final String fileType;
  final String title;

  const DocumentViewerPage({
    super.key,
    required this.url,
    required this.fileType,
    required this.title,
  });

  Future<void> _openFileExternally() async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              fileType.toUpperCase() == 'PDF'
                  ? Icons.picture_as_pdf
                  : Icons.description,
              color: Colors.blue,
              size: 100,
            ),
            const SizedBox(height: 20),
            Text(
              'Open $fileType Document',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _openFileExternally,
              child: const Text('View Document'),
            ),
          ],
        ),
      ),
    );
  }
}
