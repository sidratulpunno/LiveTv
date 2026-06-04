import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../core/app_theme.dart';
import '../../data/models/channel_model.dart';

class PlayerScreen extends StatefulWidget {
  final UnifiedChannel channel;
  const PlayerScreen({Key? key, required this.channel}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int _streamIndex = 0;
  bool _isDisposed = false;
  bool _isFullscreen = false;
  bool _controlsVisible = true;
  Timer? _hideTimer;
  late AnimationController _controlsAnimController;

  @override
  void initState() {
    super.initState();
    _controlsAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _controlsAnimController.value = 1.0;
    _startHideTimer();
    _initPlayer();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _hideTimer?.cancel();
    _controlsAnimController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    _exitFullscreen();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: 4), () {
      if (mounted && _controlsVisible) {
        setState(() => _controlsVisible = false);
        _controlsAnimController.reverse();
      }
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) {
      _controlsAnimController.forward();
      _startHideTimer();
    } else {
      _controlsAnimController.reverse();
    }
  }

  void _toggleFullscreen() {
    if (_isFullscreen) {
      _exitFullscreen();
    } else {
      _enterFullscreen();
    }
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    setState(() => _isFullscreen = true);
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    setState(() => _isFullscreen = false);
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
    }
  }

  void _changeStream(int index) {
    if (_isDisposed) return;

    final oldChewie = _chewieController;
    final oldVideo = _videoController;

    setState(() {
      _chewieController = null;
      _videoController = null;
      _streamIndex = index;
    });

    Future.delayed(Duration.zero, () async {
      oldChewie?.dispose();
      await oldVideo?.dispose();
      if (!_isDisposed) _initPlayer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isFullscreen) {
          _exitFullscreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [
              Center(
                child: _chewieController != null &&
                        _videoController != null &&
                        _videoController!.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : _buildLoadingState(),
              ),
              FadeTransition(
                opacity: _controlsAnimController,
                child: _buildControlsOverlay(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppTheme.accentColor),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Loading stream...",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay(BuildContext context) {
    return Stack(
      children: [
        // Top Gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 140,
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

        // Back Button (exits fullscreen first if in fullscreen mode)
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_isFullscreen) {
                      _exitFullscreen();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  customBorder: CircleBorder(),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isFullscreen
                          ? Icons.fullscreen_exit
                          : Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Channel Info
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
                if (widget.channel.streams.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.signal_cellular_alt,
                          size: 16, color: AppTheme.successColor),
                      SizedBox(width: 6),
                      Text(
                        widget.channel.streams[_streamIndex].quality ??
                            "Auto",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.successColor,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        // Quality Selector (top right)
        if (widget.channel.streams.length > 1)
          Positioned(
            top: 0,
            right: 12,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 12),
                child: _buildQualitySelector(context),
              ),
            ),
          ),

        // Bottom Gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 120,
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

        // Bottom Controls Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  // Stream count badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stream,
                            size: 14, color: AppTheme.accentColor),
                        SizedBox(width: 6),
                        Text(
                          '${widget.channel.streams.length} Stream${widget.channel.streams.length > 1 ? 's' : ''}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  Spacer(),

                  // Fullscreen Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _toggleFullscreen,
                        customBorder: CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            _isFullscreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        ? AppTheme.accentColor
                        : AppTheme.textHint,
                    size: 18,
                  ),
                  SizedBox(width: 12),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? AppTheme.accentColor
                              : AppTheme.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
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
