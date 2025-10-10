// lib/screens/teacher/custom_video_player_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isPlaying = false;
  String _selectedQuality = '22';
  bool _isLandscape = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
    });

    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                -webkit-user-select: none;
                user-select: none;
                -webkit-touch-callout: none;
            }
            
            html, body {
                width: 100%;
                height: 100%;
                background: #000;
                overflow: hidden;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            }
            
            body {
                display: flex;
                justify-content: center;
                align-items: center;
            }
            
            #container {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: #000;
                overflow: hidden;
                z-index: 1;
            }
            
            #player {
                width: 100%;
                height: 100%;
                position: absolute;
                top: 0;
                left: 0;
            }
            
            .player-wrapper {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                z-index: 1;
            }
            
            /* Keep iframe visible but block branding */
            iframe {
                pointer-events: none !important;
            }
            
            /* Top bar with proper spacing */
            .top-bar {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                height: 56px;
                background: rgba(0,0,0,0.3);
                backdrop-filter: blur(8px);
                -webkit-backdrop-filter: blur(8px);
                z-index: 20;
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 8px 16px;
                border-bottom: 1px solid rgba(255,255,255,0.05);
            }
            
            .back-btn {
                width: 44px;
                height: 44px;
                border-radius: 50%;
                background: rgba(255,255,255,0.1);
                border: none;
                color: white;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 20px;
                transition: background 0.2s ease;
            }
            
            .back-btn:active {
                background: rgba(255,255,255,0.2);
            }
            
            .video-title {
                color: #fff;
                font-size: 16px;
                font-weight: 500;
                flex: 1;
                margin-left: 16px;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }
            
            /* Video container with proper padding */
            .video-container {
                position: fixed;
                top: 56px;
                left: 0;
                right: 0;
                bottom: 0;
                background: #000;
                z-index: 1;
            }
            
            /* Player controls overlay */
            .controls-container {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                z-index: 10;
            }
            
            /* Center play button */
            .center-controls {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                display: flex;
                gap: 24px;
                opacity: 0;
                transition: opacity 0.2s ease;
                pointer-events: none;
                z-index: 5;
            }
            
            .center-controls.show {
                opacity: 1;
                pointer-events: auto;
            }
            
            .center-btn {
                width: 56px;
                height: 56px;
                border-radius: 50%;
                border: none;
                background: rgba(255,255,255,0.15);
                color: white;
                cursor: pointer;
                font-size: 22px;
                display: flex;
                align-items: center;
                justify-content: center;
                transition: all 0.15s ease;
                backdrop-filter: blur(8px);
                -webkit-backdrop-filter: blur(8px);
                flex-shrink: 0;
            }
            
            .center-play-btn {
                width: 72px;
                height: 72px;
                background: rgba(255,0,110,0.95);
                box-shadow: 0 12px 28px rgba(255,0,110,0.4);
                font-size: 28px;
            }
            
            .center-btn:active {
                transform: scale(0.92);
            }
            
            /* Bottom controls */
            .bottom-controls {
                position: absolute;
                bottom: 0;
                left: 0;
                right: 0;
                background: linear-gradient(180deg, transparent 0%, rgba(0,0,0,0.3) 30%, rgba(0,0,0,0.7) 100%);
                padding: 60px 16px 20px;
                opacity: 0;
                transition: opacity 0.2s ease;
                z-index: 10;
                pointer-events: none;
            }
            
            .bottom-controls.show {
                opacity: 1;
                pointer-events: auto;
            }
            
            /* Progress bar */
            .progress-section {
                width: 100%;
                margin-bottom: 16px;
                cursor: pointer;
                padding: 6px 0;
                pointer-events: auto;
            }
            
            .progress-bar {
                width: 100%;
                height: 4px;
                background: rgba(255,255,255,0.2);
                border-radius: 2px;
                position: relative;
                overflow: hidden;
                cursor: pointer;
            }
            
            .progress-fill {
                height: 100%;
                background: #ff0055;
                border-radius: 2px;
                width: 0%;
                transition: all 0.1s ease;
            }
            
            .progress-bar:hover .progress-fill {
                background: #ff006e;
                box-shadow: 0 0 8px rgba(255,0,110,0.5);
            }
            
            /* Controls row */
            .controls-row {
                display: flex;
                align-items: center;
                gap: 12px;
                justify-content: space-between;
                pointer-events: auto;
            }
            
            .controls-left {
                display: flex;
                align-items: center;
                gap: 10px;
                flex: 1;
            }
            
            .controls-right {
                display: flex;
                align-items: center;
                gap: 8px;
            }
            
            .control-btn {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                border: none;
                background: rgba(255,255,255,0.15);
                color: white;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 16px;
                transition: all 0.15s ease;
                backdrop-filter: blur(8px);
                -webkit-backdrop-filter: blur(8px);
                flex-shrink: 0;
            }
            
            .control-btn:active {
                background: rgba(255,255,255,0.25);
                transform: scale(0.95);
            }
            
            .play-btn {
                width: 44px;
                height: 44px;
                background: rgba(255,0,110,0.9);
                box-shadow: 0 4px 12px rgba(255,0,110,0.3);
            }
            
            .time-display {
                color: rgba(255,255,255,0.8);
                font-size: 12px;
                font-weight: 500;
                min-width: 70px;
                text-align: center;
                font-variant-numeric: tabular-nums;
                flex-shrink: 0;
            }
            
            .quality-dropdown {
                position: relative;
                flex-shrink: 0;
            }
            
            .quality-btn {
                font-size: 11px;
                padding: 0 8px;
                width: auto;
                min-width: 45px;
            }
            
            .quality-menu {
                display: none;
                position: absolute;
                bottom: 48px;
                right: 0;
                background: rgba(0,0,0,0.9);
                backdrop-filter: blur(16px);
                -webkit-backdrop-filter: blur(16px);
                border-radius: 10px;
                overflow: hidden;
                border: 1px solid rgba(255,255,255,0.08);
                box-shadow: 0 16px 40px rgba(0,0,0,0.6);
                min-width: 110px;
                z-index: 100;
            }
            
            .quality-menu.show {
                display: block;
            }
            
            .quality-option {
                color: rgba(255,255,255,0.7);
                padding: 10px 16px;
                cursor: pointer;
                border: none;
                background: transparent;
                width: 100%;
                text-align: center;
                font-size: 12px;
                font-weight: 500;
                transition: all 0.15s ease;
                border-left: 3px solid transparent;
                pointer-events: auto;
            }
            
            .quality-option:active {
                background: rgba(255,0,110,0.12);
            }
            
            .quality-option.active {
                color: #ff0055;
                border-left-color: #ff0055;
                font-weight: 600;
            }
            
            /* Loading spinner */
            .loading-spinner {
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                z-index: 3;
                pointer-events: none;
            }
            
            .spinner {
                width: 48px;
                height: 48px;
                border: 3px solid rgba(255,255,255,0.1);
                border-top-color: #ff0055;
                border-radius: 50%;
                animation: spin 0.8s linear infinite;
            }
            
            @keyframes spin {
                to { transform: rotate(360deg); }
            }
            
            .loading-text {
                color: rgba(255,255,255,0.5);
                text-align: center;
                margin-top: 12px;
                font-size: 10px;
                letter-spacing: 1px;
            }
            
            /* Responsive - Landscape */
            @media (orientation: landscape) {
                .top-bar {
                    height: 48px;
                    padding: 6px 12px;
                }
                
                .video-container {
                    top: 48px;
                }
                
                .video-title {
                    font-size: 14px;
                    margin-left: 12px;
                }
                
                .back-btn {
                    width: 40px;
                    height: 40px;
                    font-size: 18px;
                }
                
                .bottom-controls {
                    padding: 40px 12px 12px;
                }
                
                .center-btn {
                    width: 50px;
                    height: 50px;
                    font-size: 20px;
                }
                
                .center-play-btn {
                    width: 64px;
                    height: 64px;
                    font-size: 24px;
                }
                
                .center-controls {
                    gap: 20px;
                }
                
                .control-btn {
                    width: 38px;
                    height: 38px;
                    font-size: 14px;
                }
                
                .play-btn {
                    width: 40px;
                    height: 40px;
                }
                
                .time-display {
                    font-size: 11px;
                    min-width: 65px;
                }
                
                .controls-row {
                    gap: 10px;
                }
            }
        </style>
    </head>
    <body oncontextmenu="return false;">
        <div id="container">
            <!-- Top bar -->
            <div class="top-bar">
                <button class="back-btn" onclick="closePlayer()">‹</button>
                <div class="video-title">Video</div>
            </div>
            
            <!-- Video area -->
            <div class="video-container">
                <div class="player-wrapper">
                    <div id="player"></div>
                </div>
                
                <!-- Controls overlay -->
                <div class="controls-container">
                    <!-- Center controls -->
                    <div class="center-controls" id="centerControls">
                        <button class="center-btn" onclick="rewind10()">⏪</button>
                        <button class="center-play-btn" id="centerPlayBtn" onclick="togglePlay()">▶</button>
                        <button class="center-btn" onclick="forward10()">⏩</button>
                    </div>
                    
                    <!-- Bottom controls -->
                    <div class="bottom-controls" id="bottomControls">
                        <div class="progress-section" onclick="seekVideo(event)">
                            <div class="progress-bar">
                                <div class="progress-fill" id="progressFill"></div>
                            </div>
                        </div>
                        
                        <div class="controls-row">
                            <div class="controls-left">
                                <button class="control-btn play-btn" id="playBtn" onclick="togglePlay()">▶</button>
                                <div class="time-display">
                                    <span id="currentTime">0:00</span>/<span id="duration">0:00</span>
                                </div>
                            </div>
                            
                            <div class="controls-right">
                                <div class="quality-dropdown">
                                    <button class="control-btn quality-btn" onclick="toggleQualityMenu()">
                                        <span id="qualityDisplay">720p</span>
                                    </button>
                                    <div class="quality-menu" id="qualityMenu">
                                        <button class="quality-option active" data-quality="22" onclick="changeQuality('22')">720p</button>
                                        <button class="quality-option" data-quality="18" onclick="changeQuality('18')">360p</button>
                                    </div>
                                </div>
                                <button class="control-btn" onclick="toggleRotation()">⟲</button>
                                <button class="control-btn" onclick="toggleFullscreen()">⛶</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Loading spinner -->
            <div class="loading-spinner" id="loadingSpinner">
                <div class="spinner"></div>
                <div class="loading-text">LOADING</div>
            </div>
        </div>

        <script>
            var tag = document.createElement('script');
            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
            
            var player;
            var hideTimer;
            
            function onYouTubeIframeAPIReady() {
                player = new YT.Player('player', {
                    videoId: '${widget.videoId}',
                    playerVars: {
                        'autoplay': 0,
                        'controls': 0,
                        'modestbranding': 1,
                        'rel': 0,
                        'showinfo': 0,
                        'fs': 0,
                        'playsinline': 1,
                        'iv_load_policy': 3,
                        'disablekb': 1,
                        'enablejsapi': 1,
                        'cc_load_policy': 0
                    },
                    events: {
                        'onReady': onPlayerReady,
                        'onStateChange': onPlayerStateChange
                    }
                });
                
                setInterval(updateProgress, 200);
                setupListeners();
                document.getElementById('loadingSpinner').style.display = 'none';
            }
            
            function setupListeners() {
                var container = document.getElementById('container');
                container.addEventListener('mousemove', showControls);
                container.addEventListener('touchstart', showControls);
                container.addEventListener('touchmove', showControls);
                container.addEventListener('mouseleave', () => {
                    if (player && player.getPlayerState() === YT.PlayerState.PLAYING) {
                        setTimeout(hideControls, 2000);
                    }
                });
            }
            
            function onPlayerReady(event) {
                document.getElementById('loadingSpinner').style.display = 'none';
            }
            
            function onPlayerStateChange(event) {
                if (event.data === YT.PlayerState.PLAYING) {
                    document.getElementById('playBtn').textContent = '⏸';
                    document.getElementById('centerPlayBtn').textContent = '⏸';
                } else if (event.data === YT.PlayerState.PAUSED) {
                    document.getElementById('playBtn').textContent = '▶';
                    document.getElementById('centerPlayBtn').textContent = '▶';
                }
            }
            
            function togglePlay() {
                if (!player) return;
                if (player.getPlayerState() === YT.PlayerState.PLAYING) {
                    player.pauseVideo();
                } else {
                    player.playVideo();
                }
                showControls();
            }
            
            function updateProgress() {
                if (!player) return;
                var current = player.getCurrentTime() || 0;
                var duration = player.getDuration() || 0;
                var percent = duration > 0 ? (current / duration) * 100 : 0;
                
                document.getElementById('progressFill').style.width = percent + '%';
                document.getElementById('currentTime').textContent = formatTime(current);
                document.getElementById('duration').textContent = formatTime(duration);
            }
            
            function formatTime(seconds) {
                var h = Math.floor(seconds / 3600);
                var m = Math.floor((seconds % 3600) / 60);
                var s = Math.floor(seconds % 60);
                
                if (h > 0) {
                    return h + ':' + (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
                }
                return m + ':' + (s < 10 ? '0' : '') + s;
            }
            
            function seekVideo(event) {
                var bar = event.currentTarget.querySelector('.progress-bar');
                var rect = bar.getBoundingClientRect();
                var percent = (event.clientX || event.touches[0].clientX - rect.left) / rect.width;
                player.seekTo(percent * player.getDuration());
                showControls();
            }
            
            function rewind10() {
                player.seekTo(Math.max(0, player.getCurrentTime() - 10));
                showControls();
            }
            
            function forward10() {
                player.seekTo(Math.min(player.getDuration(), player.getCurrentTime() + 10));
                showControls();
            }
            
            function toggleQualityMenu() {
                document.getElementById('qualityMenu').classList.toggle('show');
            }
            
            function changeQuality(itag) {
                var current = player.getCurrentTime();
                var wasPlaying = player.getPlayerState() === YT.PlayerState.PLAYING;
                
                player.loadVideoById({
                    videoId: '${widget.videoId}',
                    startSeconds: current
                });
                
                if (wasPlaying) {
                    setTimeout(() => player.playVideo(), 500);
                }
                
                document.querySelectorAll('.quality-option').forEach(btn => {
                    btn.classList.remove('active');
                });
                document.querySelector('[data-quality="' + itag + '"]').classList.add('active');
                document.getElementById('qualityDisplay').textContent = itag === '22' ? '720p' : '360p';
                document.getElementById('qualityMenu').classList.remove('show');
            }
            
            function toggleFullscreen() {
                var container = document.getElementById('container');
                if (!document.fullscreenElement) {
                    (container.requestFullscreen || container.webkitRequestFullscreen).call(container).catch(e => {});
                } else {
                    (document.exitFullscreen || document.webkitExitFullscreen).call(document);
                }
                showControls();
            }
            
            function toggleRotation() {
                window.flutter_inappwebview.callHandler('toggleRotation', {});
            }
            
            function showControls() {
                clearTimeout(hideTimer);
                document.getElementById('centerControls').classList.add('show');
                document.getElementById('bottomControls').classList.add('show');
                
                if (player && player.getPlayerState() === YT.PlayerState.PLAYING) {
                    hideTimer = setTimeout(hideControls, 3000);
                }
            }
            
            function hideControls() {
                document.getElementById('centerControls').classList.remove('show');
                document.getElementById('bottomControls').classList.remove('show');
            }
            
            function closePlayer() {
                window.flutter_inappwebview.callHandler('closePlayer', {});
            }
            
            document.addEventListener('touchstart', () => {
                clearTimeout(hideTimer);
                showControls();
            });
        </script>
    </body>
    </html>
    ''';

    return Scaffold(
      backgroundColor: Colors.black,
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
              javaScriptCanOpenWindowsAutomatically: true,
              disableDefaultErrorPage: true,
              useShouldOverrideUrlLoading: true,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
              controller.addJavaScriptHandler(
                handlerName: 'closePlayer',
                callback: (args) {
                  Navigator.pop(context);
                },
              );
              controller.addJavaScriptHandler(
                handlerName: 'toggleRotation',
                callback: (args) {
                  _toggleOrientation();
                },
              );
            },
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) {
              setState(() => _isLoading = false);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return NavigationActionPolicy.CANCEL;
            },
          ),
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFff0055),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'LOADING',
                    style: TextStyle(
                      color: Color(0xFFff0055),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}