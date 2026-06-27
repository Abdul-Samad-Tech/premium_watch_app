import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:logger/logger.dart';

/// Full-Screen Video Background Widget
/// Uses WebM format for better web/mobile compatibility
/// Video plays muted and looped across the entire app
class FullScreenVideoBackground extends StatefulWidget {
  final Widget child;
  final String videoPath;

  const FullScreenVideoBackground({
    super.key,
    required this.child,
    this.videoPath = 'assets/videos/background-app.webm',
  });

  @override
  State<FullScreenVideoBackground> createState() =>
      _FullScreenVideoBackgroundState();
}

class _FullScreenVideoBackgroundState extends State<FullScreenVideoBackground> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _logger.d('Initializing video: ${widget.videoPath}');
      _videoController = VideoPlayerController.asset(widget.videoPath);
      await _videoController!.initialize();

      if (_videoController!.value.duration.inMilliseconds > 0) {
        _videoController!
          ..setLooping(true)
          ..setVolume(0.0) // Muted
          ..play();

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
        _logger.d('Video initialized successfully');
      } else {
        _logger.d('Video file is empty');
        if (mounted) {
          setState(() {
            _isInitialized = false;
          });
        }
      }
    } catch (e) {
      _logger.d('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 1: Video Background
        _buildVideoLayer(),

        // Layer 2: Semi-transparent Overlay (for readability)
        Container(color: Colors.black.withValues(alpha: 0.5)),

        // Layer 3: App Content
        widget.child,
      ],
    );
  }

  Widget _buildVideoLayer() {
    if (_isInitialized && _videoController != null) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    }

    // Fallback: Premium Dark Gradient
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0A0A0A),
          ],
        ),
      ),
    );
  }
}

/// Wrapper for screens that need full-screen video background
/// Usage: Wrap your screen with VideoBackgroundWrapper
class VideoBackgroundWrapper extends StatelessWidget {
  final Widget child;
  final String videoPath;

  const VideoBackgroundWrapper({
    super.key,
    required this.child,
    this.videoPath = 'assets/videos/background-app.webm',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FullScreenVideoBackground(videoPath: videoPath, child: child),
    );
  }
}
