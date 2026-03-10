import 'dart:io' as java_io;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../core/theme/aether_theme.dart';

/// ─── Video Thumbnail Widget ─────────────────────────────────────────────────
/// Plays a looping video preview from assets. Used in grid cards and viewer.
/// ─────────────────────────────────────────────────────────────────────────────

class VideoThumbnail extends StatefulWidget {
  final String assetPath;
  final BoxFit fit;
  final bool autoPlay;
  final bool showPlayIcon;

  const VideoThumbnail({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.autoPlay = true,
    this.showPlayIcon = false,
  });

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.asset(widget.assetPath);
    try {
      await _controller.initialize();
      _controller.setLooping(true);
      _controller.setVolume(0);
      if (widget.autoPlay) {
        _controller.play();
      }
      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: AetherColors.charcoalLight,
        child: const Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: AetherColors.white30,
            size: 32,
          ),
        ),
      );
    }

    if (!_initialized) {
      return Container(
        color: AetherColors.charcoalLight,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AetherColors.electricCyan),
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: widget.fit,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
        if (widget.showPlayIcon && !_controller.value.isPlaying)
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AetherColors.charcoal.withOpacity(0.6),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AetherColors.electricCyan,
                size: 32,
              ),
            ),
          ),
      ],
    );
  }
}

/// Full-screen video player for file-based videos (user uploads).
class FullScreenFileVideoPlayer extends StatefulWidget {
  final String filePath;

  const FullScreenFileVideoPlayer({
    super.key,
    required this.filePath,
  });

  @override
  State<FullScreenFileVideoPlayer> createState() =>
      _FullScreenFileVideoPlayerState();
}

class _FullScreenFileVideoPlayerState extends State<FullScreenFileVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(java_io.File(widget.filePath))
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
        if (mounted) setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        color: AetherColors.charcoal,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AetherColors.electricCyan),
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}

/// Full-screen video player for the wallpaper viewer screen.
class FullScreenVideoPlayer extends StatefulWidget {
  final String assetPath;

  const FullScreenVideoPlayer({
    super.key,
    required this.assetPath,
  });

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
        if (mounted) setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        color: AetherColors.charcoal,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AetherColors.electricCyan),
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
