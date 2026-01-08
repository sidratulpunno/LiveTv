import 'package:audio_session/audio_session.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../data/models/channel_model.dart';

class PlayerScreen extends StatefulWidget {
  final UnifiedChannel channel;
  const PlayerScreen({Key? key, required this.channel}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int _streamIndex = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.music());
    } catch (e) {
      // Ignore web errors
    }

    final stream = widget.channel.streams[_streamIndex];

    final newVideoController = VideoPlayerController.networkUrl(
      Uri.parse(stream.url),
      httpHeaders: {}, // Add headers if needed for mobile
    );

    try {
      await newVideoController.initialize();

      if (_isDisposed || !mounted) {
        await newVideoController.dispose();
        return;
      }

      final newChewieController = ChewieController(
        videoPlayerController: newVideoController,
        autoPlay: true,
        looping: false,
        draggableProgressBar: false, // Live stream optimization
        isLive: true,
        showOptions: false, // Hide default controls to use our custom ones
        aspectRatio: newVideoController.value.aspectRatio,
        errorBuilder: (context, error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white54, size: 40),
              SizedBox(height: 10),
              Text("Stream Error", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );

      setState(() {
        _videoController = newVideoController;
        _chewieController = newChewieController;
      });
    } catch (e) {
      if (!mounted) return;
      print("Error initializing stream: $e");
    }
  }

  void _changeStream(int index) {
    if (_isDisposed) return;
    setState(() {
      _chewieController = null;
      _videoController = null;
      _streamIndex = index;
    });

    final oldChewie = _chewieController;
    final oldVideo = _videoController;

    Future.delayed(Duration.zero, () async {
      oldChewie?.dispose();
      await oldVideo?.dispose();
      if (!_isDisposed) _initPlayer();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Video Layer
          Center(
            child: _chewieController != null &&
                _videoController != null &&
                _videoController!.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : CircularProgressIndicator(color: Colors.white),
          ),

          // 2. Gradient Overlay (Top) - Ensures buttons are visible
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Back Button
          // Positioned(
          //   top: 40,
          //   left: 20,
          //   child: SafeArea(
          //     child: GestureDetector(
          //       onTap: () => Navigator.pop(context),
          //       child: Container(
          //         padding: EdgeInsets.all(8),
          //         decoration: BoxDecoration(
          //           color: Colors.white.withOpacity(0.1),
          //           shape: BoxShape.circle,
          //         ),
          //         child: Icon(Icons.arrow_back, color: Colors.white),
          //       ),
          //     ),
          //   ),
          // ),

          // 4. Quality Selector
          if (widget.channel.streams.length > 1)
            Positioned(
              top: 40,
              right: 20,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: PopupMenuButton<int>(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.settings, color: Colors.white, size: 20),
                        SizedBox(width: 4),
                        Text(
                          "Sources",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    tooltip: "Select Source",
                    color: Color(0xFF1E1E1E), // Dark menu background
                    onSelected: _changeStream,
                    itemBuilder: (context) => List.generate(
                      widget.channel.streams.length,
                          (index) {
                        final s = widget.channel.streams[index];
                        String label = "Source ${index + 1}";
                        if (s.quality != null && s.quality!.isNotEmpty) {
                          label += " • ${s.quality}";
                        }
                        final isSelected = index == _streamIndex;

                        return PopupMenuItem(
                          value: index,
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? Colors.blueAccent
                                    : Colors.white54,
                                size: 18,
                              ),
                              SizedBox(width: 12),
                              Text(
                                label,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.blueAccent
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}