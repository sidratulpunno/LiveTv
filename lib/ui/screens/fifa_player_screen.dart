import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../core/app_theme.dart';
import '../../data/models/fifa_channel_model.dart';
import '../utils/fullscreen_helper.dart' as fs;

class FifaPlayerScreen extends StatefulWidget {
  final List<FifaChannel> channels;

  const FifaPlayerScreen({Key? key, required this.channels}) : super(key: key);

  @override
  _FifaPlayerScreenState createState() => _FifaPlayerScreenState();
}

class _FifaPlayerScreenState extends State<FifaPlayerScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int _currentIndex = 0;
  bool _isDisposed = false;
  bool _isFullscreen = false;
  bool _controlsVisible = true;
  bool _isLoading = true;
  String _loadingMessage = 'Connecting...';
  Timer? _hideTimer;
  int _fallbackAttempts = 0;
  int _initGeneration = 0;
  static const int _maxFallbackAttempts = 10;
  static const Duration _initTimeout = Duration(seconds: 12);
  late AnimationController _controlsAnimController;

  late List<FifaChannel> _sortedChannels;

  @override
  void initState() {
    super.initState();
    _controlsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _controlsAnimController.value = 1.0;
    _sortedChannels = List.from(widget.channels)
      ..sort((a, b) => b.qualityScore.compareTo(a.qualityScore));
    _initPlayer();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _hideTimer?.cancel();
    _controlsAnimController.dispose();
    _disposeCurrentPlayer();
    _exitFullscreen();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _controlsVisible) {
        setState(() => _controlsVisible = false);
        _controlsAnimController.reverse();
      }
    });
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    _controlsAnimController.forward();
    _startHideTimer();
  }

  void _toggleControls() {
    if (_controlsVisible) {
      setState(() => _controlsVisible = false);
      _controlsAnimController.reverse();
      _hideTimer?.cancel();
    } else {
      _showControls();
    }
  }

  void _onVideoError() {
    if (_isDisposed || !mounted) return;
    if (_videoController != null && _videoController!.value.hasError) {
      _autoSwitchToNext();
    }
  }

  Future<void> _initPlayer() async {
    final generation = ++_initGeneration;

    if (_currentIndex >= _sortedChannels.length) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final channel = _sortedChannels[_currentIndex];
    setState(() {
      _isLoading = true;
      _controlsVisible = true;
      _controlsAnimController.forward();
      _loadingMessage = 'Connecting to ${channel.name}...';
    });
    _hideTimer?.cancel();

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(channel.url),
      );

      await controller.initialize().timeout(_initTimeout, onTimeout: () {
        controller.dispose();
        throw TimeoutException('Stream initialization timed out');
      });

      if (_isDisposed || !mounted || generation != _initGeneration) {
        await controller.dispose();
        return;
      }

      controller.addListener(_onVideoError);

      double aspectRatio = controller.value.aspectRatio;
      if (!aspectRatio.isFinite || aspectRatio <= 0) {
        aspectRatio = 16 / 9;
      }

      final chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        isLive: true,
        showControls: false,
        showOptions: false,
        draggableProgressBar: false,
        aspectRatio: aspectRatio,
      );

      if (_isDisposed || generation != _initGeneration) {
        await controller.dispose();
        chewieController.dispose();
        return;
      }

      controller.play();
      _startHideTimer();

      setState(() {
        _videoController = controller;
        _chewieController = chewieController;
        _isLoading = false;
        _fallbackAttempts = 0;
      });
    } on TimeoutException {
      if (!mounted || generation != _initGeneration) return;
      _autoSwitchToNext();
    } catch (e) {
      if (!mounted || generation != _initGeneration) return;
      _autoSwitchToNext();
    }
  }

  void _autoSwitchToNext() {
    if (_isDisposed || !mounted) return;
    if (_fallbackAttempts >= _maxFallbackAttempts) {
      setState(() => _isLoading = false);
      return;
    }
    _fallbackAttempts++;
    _disposeCurrentPlayer();
    _currentIndex = (_currentIndex + 1) % _sortedChannels.length;
    _initPlayer();
  }

  void _switchToChannel(int index) {
    if (index == _currentIndex) return;
    _disposeCurrentPlayer();
    setState(() => _currentIndex = index);
    _showControls();
    _initPlayer();
  }

  void _disposeCurrentPlayer() {
    if (_videoController != null) {
      _videoController!.removeListener(_onVideoError);
    }
    _chewieController?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;
  }

  void _toggleFullscreen() {
    if (_isFullscreen) {
      _exitFullscreen();
    } else {
      _enterFullscreen();
    }
  }

  void _enterFullscreen() {
    fs.enterFullscreen();
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    setState(() => _isFullscreen = true);
  }

  void _exitFullscreen() {
    fs.exitFullscreen();
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
    setState(() => _isFullscreen = false);
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
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppTheme.accentColor),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isLoading ? _loadingMessage : 'No working streams found',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Stream ${_currentIndex + 1} of ${_sortedChannels.length}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textHint),
                ),
              ),
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextButton.icon(
                  onPressed: () {
                    _fallbackAttempts = 0;
                    _currentIndex = 0;
                    _initPlayer();
                  },
                  icon: const Icon(Icons.refresh, color: AppTheme.accentColor),
                  label: const Text('Retry',
                      style: TextStyle(color: AppTheme.accentColor)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _startHideTimer(),
      child: Stack(
        children: [
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
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white.withOpacity(0.25)),
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
          Positioned(
            top: 60,
            left: 16,
            right: 80,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _sortedChannels[_currentIndex].name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.signal_cellular_alt,
                          size: 16, color: AppTheme.successColor),
                      const SizedBox(width: 6),
                      Text(
                        '${_currentIndex + 1} / ${_sortedChannels.length}',
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
          Positioned(
            top: 0,
            right: 12,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildChannelSelector(context),
              ),
            ),
          ),
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stream,
                              size: 14, color: AppTheme.accentColor),
                          const SizedBox(width: 6),
                          Text(
                            '${_sortedChannels.length} Channels',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _toggleFullscreen,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
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
      ),
    );
  }

  Widget _buildChannelSelector(BuildContext context) {
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
            const SizedBox(width: 8),
            const Icon(Icons.list, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              "Channels",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(width: 8),
          ],
        ),
        tooltip: "Select Channel",
        color: AppTheme.darkSurface,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: _switchToChannel,
        itemBuilder: (context) => List.generate(
          _sortedChannels.length,
          (index) {
            final ch = _sortedChannels[index];
            final isSelected = index == _currentIndex;

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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ch.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: isSelected
                                    ? AppTheme.accentColor
                                    : AppTheme.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Quality: ${_qualityLabel(ch.qualityScore)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textHint),
                        ),
                      ],
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

  String _qualityLabel(int score) {
    switch (score) {
      case 5:
        return '4K';
      case 4:
        return '1080p';
      case 3:
        return '720p';
      case 2:
        return 'SD';
      default:
        return 'Auto';
    }
  }
}
