import 'package:audio_session/audio_session.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/app_theme.dart';
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
  bool _showControls = true;

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
      httpHeaders: {},
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
        draggableProgressBar: false,
        isLive: true,
        showOptions: false,
        aspectRatio: newVideoController.value.aspectRatio,
        errorBuilder: (context, error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                        color: AppTheme.errorColor, size: 48),
                    SizedBox(height: 16),
                    Text(
                      "Stream Error",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Unable to load this stream",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
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
                : Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              AppTheme.accentColor,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Loading stream...",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // 2. Top Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Back Button with modern design
          Positioned(
            top: 20,
            left: 16,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  customBorder: CircleBorder(),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child:
                        Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ),

          // 4. Channel Info
          Positioned(
            top: 60,
            left: 16,
            right: 80,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.channel.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.channel.streams.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.signal_cellular_alt,
                            size: 16, color: AppTheme.successColor),
                        SizedBox(width: 6),
                        Text(
                          widget.channel.streams[_streamIndex].quality ??
                              "Auto",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.successColor),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // 5. Quality Selector
          if (widget.channel.streams.length > 1)
            Positioned(
              top: 20,
              right: 16,
              child: SafeArea(
                child: _buildQualitySelector(context),
              ),
            ),

          // 6. Bottom Info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // 7. Stream Count at bottom
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stream, size: 14, color: AppTheme.accentColor),
                  SizedBox(width: 6),
                  Text(
                    '${widget.channel.streams.length} Stream${widget.channel.streams.length > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: PopupMenuButton<int>(
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 8),
            Icon(Icons.hd, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              "Sources",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            SizedBox(width: 8),
          ],
        ),
        tooltip: "Select Source",
        color: AppTheme.darkSurface,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? AppTheme.accentColor : AppTheme.textHint,
                    size: 18,
                  ),
                  SizedBox(width: 12),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? AppTheme.accentColor
                              : AppTheme.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
