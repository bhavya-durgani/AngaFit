import 'dart:async'; // For Future, Timer, async operations
import 'dart:typed_data'; // For Uint8List (raw image bytes)

import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:ui' as ui; // For blur effects (BackdropFilter)

import '../../core/constants/app_colors.dart'; // Custom app colors
import '../../data/dummy_data.dart'; // Product model (dummy data)

/// Shows the 360° try-on result as a smoothly looping video-like animation.
/// All result images are pre-downloaded to memory so playback is gapless.
class ThreeSixtyResultScreen extends StatefulWidget {
  final List<Uint8List> capturedImages; // Original captured frames
  final List<String?> resultUrls; // AI-generated image URLs
  final Product product; // Product info
  final String selectedSize; // Selected size

  const ThreeSixtyResultScreen({
    super.key,
    required this.capturedImages,
    required this.resultUrls,
    required this.product,
    required this.selectedSize,
  });

  @override
  State<ThreeSixtyResultScreen> createState() => _ThreeSixtyResultScreenState();
}

class _ThreeSixtyResultScreenState extends State<ThreeSixtyResultScreen>
    with TickerProviderStateMixin {

  // ── Data ─────────────────────────────────────────────────────────────────
  List<Uint8List> _resultFrames = []; // AI-generated frames (downloaded)
  List<Uint8List> _originalFrames = []; // Original frames for comparison
  bool _isLoading = true; // Loading state
  String? _loadError; // Error message

  // ── Playback ─────────────────────────────────────────────────────────────
  late AnimationController _aniCtrl; // Controls frame animation
  bool _isPlaying = true; // Whether animation is playing
  bool _showOriginal = false; // Toggle between AI vs original

  // ── Gesture scrub ────────────────────────────────────────────────────────
  double _dragStartX = 0; // Start position of swipe
  int _scrubIndex = 0; // Current frame index while scrubbing

  @override
  void initState() {
    super.initState();

    // Loop through result URLs and keep only valid ones
    for (int i = 0; i < widget.resultUrls.length; i++) {
      if (widget.resultUrls[i] != null && i < widget.capturedImages.length) {
        _originalFrames.add(widget.capturedImages[i]); // Store matching original frame
      }
    }

    // Temporary animation controller (will be updated later)
    _aniCtrl = AnimationController(
      vsync: this, // Sync animation with screen refresh
      duration: const Duration(milliseconds: 800), // Placeholder duration
    );

    _downloadAll(); // Start downloading AI images
  }

  // ── Download all result images ───────────────────────────────────────────
  Future<void> _downloadAll() async {
    final urls = widget.resultUrls.whereType<String>().toList(); // Remove nulls
    final frames = <Uint8List>[]; // Store downloaded frames

    for (final url in urls) {
      try {
        final res = await http
            .get(Uri.parse(url)) // Fetch image
            .timeout(const Duration(seconds: 30)); // Timeout safety

        if (res.statusCode == 200) {
          frames.add(res.bodyBytes); // Store image bytes
        }
      } catch (e) {
        debugPrint('[360Result] Download err: $e'); // Log error
      }
    }

    if (!mounted) return; // Stop if widget disposed

    if (frames.isEmpty) {
      setState(() {
        _isLoading = false;
        _loadError = 'Could not load any result images.'; // Error state
      });
      return;
    }

    // Recreate animation controller based on number of frames
    _aniCtrl.dispose(); // Dispose old one
    _aniCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100 * frames.length), // 100ms per frame (~10 FPS)
    );

    // Preload images into cache for smooth playback
    for (final bytes in frames) {
      await precacheImage(MemoryImage(bytes), context);
    }

    setState(() {
      _resultFrames = frames; // Save frames
      _isLoading = false; // Stop loading
    });

    _aniCtrl.repeat(); // Start looping animation
  }

  // ── Playback control ─────────────────────────────────────────────────────
  void _togglePlayback() {
    setState(() => _isPlaying = !_isPlaying); // Toggle play state

    if (_isPlaying) {
      _aniCtrl.repeat(); // Resume animation
    } else {
      _aniCtrl.stop(); // Pause animation
    }
  }

  // Get current frame index
  int get _currentFrameIndex {
    if (_resultFrames.isEmpty) return 0;

    if (!_isPlaying) {
      return _scrubIndex.clamp(0, _resultFrames.length - 1); // Manual scrub mode
    }

    final idx = (_aniCtrl.value * _resultFrames.length).floor(); // Convert animation value to index
    return idx.clamp(0, _resultFrames.length - 1);
  }

  @override
  void dispose() {
    _aniCtrl.dispose(); // Clean up animation controller
    super.dispose();
  }

  // ── UI Builder ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScreen(); // Show loading
    if (_loadError != null) return _buildErrorScreen(); // Show error
    return _buildResultScreen(); // Show result
  }

  // ── Loading Screen ───────────────────────────────────────────────────────
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.primaryRed,
                    strokeWidth: 3,
                  ),
                  const Icon(Icons.auto_awesome,
                      color: AppColors.primaryRed, size: 36),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Preparing your 360° video…',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error Screen ─────────────────────────────────────────────────────────
  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(_loadError ?? 'Unknown error'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context), // Go back
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main Result Screen ───────────────────────────────────────────────────
  Widget _buildResultScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          // ── Gesture handling (swipe + hold) ──────────────────────────────
          GestureDetector(
            onPanStart: (d) {
              _aniCtrl.stop(); // Stop animation
              setState(() {
                _isPlaying = false;
                _dragStartX = d.globalPosition.dx; // Store start position
                _scrubIndex = _currentFrameIndex;
              });
            },
            onPanUpdate: (d) {
              final delta = d.globalPosition.dx - _dragStartX;
              final step = delta ~/ 20; // Convert pixels to frame step
              setState(() {
                _scrubIndex = (_currentFrameIndex - step)
                    .clamp(0, _resultFrames.length - 1);
              });
            },

            // Long press → show original image
            onLongPressStart: (_) =>
                setState(() => _showOriginal = true),

            onLongPressEnd: (_) =>
                setState(() => _showOriginal = false),

            child: SizedBox.expand(
              child: AnimatedBuilder(
                animation: _aniCtrl,
                builder: (_, __) {
                  final idx = _currentFrameIndex;

                  final bytes = _showOriginal &&
                          idx < _originalFrames.length
                      ? _originalFrames[idx] // Show original
                      : _resultFrames[idx]; // Show AI result

                  return Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                    gaplessPlayback: true, // Smooth transition
                  );
                },
              ),
            ),
          ),

          // ── Bottom Controls ──────────────────────────────────────────────
          Positioned(
            bottom: 28,
            left: 20,
            right: 20,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _togglePlayback, // Play/Pause
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context), // Done
                    child: const Text('DONE'),
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
