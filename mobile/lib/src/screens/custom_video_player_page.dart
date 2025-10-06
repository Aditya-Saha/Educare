// lib/screens/teacher/custom_video_player_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CustomVideoPlayerPage extends StatefulWidget {
  final String videoId;
  const CustomVideoPlayerPage({super.key, required this.videoId});

  @override
  State<CustomVideoPlayerPage> createState() => _CustomVideoPlayerPageState();
}

class _CustomVideoPlayerPageState extends State<CustomVideoPlayerPage> {
  late InAppWebViewController webViewController;
  double _progress = 0;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final String htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * { margin: 0; padding: 0; overflow: hidden; }
            body { background-color: #000; display: flex; justify-content: center; align-items: center; height: 100vh; }
            #player { width: 100vw; height: 100vh; }
        </style>
    </head>
    <body>
        <div id="player"></div>
        <script>
            var tag = document.createElement('script');
            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
            var player;
            function onYouTubeIframeAPIReady() {
                player = new YT.Player('player', {
                    videoId: '${widget.videoId}',
                    playerVars: {
                        'autoplay': 1,
                        'controls': 1,
                        'modestbranding': 1,
                        'rel': 0,
                        'showinfo': 0,
                        'fs': 1,
                        'playsinline': 1
                    },
                    events: { 'onReady': onPlayerReady }
                });
            }
            function onPlayerReady(event) { event.target.playVideo(); }
        </script>
    </body>
    </html>
    ''';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Video Player", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(data: htmlContent),
            initialSettings: InAppWebViewSettings(
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              javaScriptEnabled: true,
              useHybridComposition: true,
              transparentBackground: true,
            ),
            onWebViewCreated: (controller) => webViewController = controller,
            onLoadStart: (controller, url) => setState(() => _isLoading = true),
            onLoadStop: (controller, url) => setState(() => _isLoading = false),
            onProgressChanged: (controller, progress) => setState(() => _progress = progress / 100),
          ),
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  const SizedBox(height: 16),
                  Text("${(_progress * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}