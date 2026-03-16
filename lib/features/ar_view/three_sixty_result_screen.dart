import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';

/// Shows the 360° try-on result as a smoothly looping video-like animation.
/// All result images are pre-downloaded to memory so playback is gapless.
class ThreeSixtyResultScreen extends StatefulWidget {
  final List<Uint8List> capturedImages;
  final List<String?> resultUrls;
  final Product product;
  final String selectedSize;

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
  List<Uint8List> _resultFrames = [];
  List<Uint8List> _originalFrames = [];
  bool _isLoading = true;
  String? _loadError;

  // ── Playback ─────────────────────────────────────────────────────────────
  /// AnimationController drives the frame index — 100 ms per frame ≈ 10 fps
  late AnimationController _aniCtrl;
  bool _isPlaying = true;
  bool _showOriginal = false;

  // ── Gesture scrub ────────────────────────────────────────────────────────
  double _dragStartX = 0;
  int _scrubIndex = 0;

  @override
  void initState() {
    super.initState();

    // Collect non-null originals paired with their result URLs
    for (int i = 0; i < widget.resultUrls.length; i++) {
      if (widget.resultUrls[i] != null && i < widget.capturedImages.length) {
        _originalFrames.add(widget.capturedImages[i]);
      }
    }

    // Placeholder controller — will be properly initialised after download
    _aniCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _downloadAll();
  }

  // ── Download all result images to RAM ────────────────────────────────────
  Future<void> _downloadAll() async {
    final urls = widget.resultUrls.whereType<String>().toList();
    final frames = <Uint8List>[];

    for (final url in urls) {
      try {
        final res = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 30));
        if (res.statusCode == 200) {
          frames.add(res.bodyBytes);
        }
      } catch (e) {
        debugPrint('[360Result] Download err: $e');
      }
    }

    if (!mounted) return;

    if (frames.isEmpty) {
      setState(() {
        _isLoading = false;
        _loadError = 'Could not load any result images.';
      });
      return;
    }

    // Re-initialise controller now we know the frame count
    _aniCtrl.dispose();
    _aniCtrl = AnimationController(
      vsync: this,
      // 100 ms per frame → smooth ~10 fps loop
      duration: Duration(milliseconds: 100 * frames.length),
    );

    // Pre-warm the image cache so the first playback cycle is smooth
    for (final bytes in frames) {
      await precacheImage(MemoryImage(bytes), context);
    }

    setState(() {
      _resultFrames = frames;
      _isLoading = false;
    });

    _aniCtrl.repeat();
  }

  // ── Playback controls ────────────────────────────────────────────────────
  void _togglePlayback() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _aniCtrl.repeat();
    } else {
      _aniCtrl.stop();
    }
  }

  int get _currentFrameIndex {
    if (_resultFrames.isEmpty) return 0;
    // During manual scrub, use _scrubIndex
    if (!_isPlaying) return _scrubIndex.clamp(0, _resultFrames.length - 1);
    // Derive index from animation value
    final idx = (_aniCtrl.value * _resultFrames.length).floor();
    return idx.clamp(0, _resultFrames.length - 1);
  }

  @override
  void dispose() {
    _aniCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScreen();
    if (_loadError != null) return _buildErrorScreen();
    return _buildResultScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated spinner with gradient ring
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Downloading AI-generated frames',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: Colors.redAccent, size: 56),
            const SizedBox(height: 16),
            Text(
              _loadError ?? 'Unknown error',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go back'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('360° Fit Result',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // ── Radial gradient background ──────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [Color(0xFF1E1E1E), Colors.black],
              ),
            ),
          ),

          // ── Main animated frame ─────────────────────────────────────────
          GestureDetector(
            // Swipe to scrub manually
            onPanStart: (d) {
              _aniCtrl.stop();
              setState(() {
                _isPlaying = false;
                _dragStartX = d.globalPosition.dx;
                _scrubIndex = _currentFrameIndex;
              });
            },
            onPanUpdate: (d) {
              final delta = d.globalPosition.dx - _dragStartX;
              final step = delta ~/ 20; // pixels per frame
              setState(() {
                _scrubIndex = (_currentFrameIndex - step)
                    .clamp(0, _resultFrames.length - 1);
              });
            },
            // Long-press to compare with original
            onLongPressStart: (_) =>
                setState(() => _showOriginal = true),
            onLongPressEnd: (_) =>
                setState(() => _showOriginal = false),
            child: SizedBox.expand(
              child: AnimatedBuilder(
                animation: _aniCtrl,
                builder: (_, __) {
                  final idx = _currentFrameIndex;
                  final showOrig = _showOriginal &&
                      idx < _originalFrames.length;
                  final bytes =
                      showOrig ? _originalFrames[idx] : _resultFrames[idx];
                  return Image.memory(
                    bytes,
                    key: ValueKey('${_showOriginal ? "o" : "r"}_$idx'),
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  );
                },
              ),
            ),
          ),

          // ── Product info card (glassmorphic) ────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.product.imageUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.product.brand,
                                style: TextStyle(
                                    color:
                                        Colors.white.withOpacity(0.6),
                                    fontSize: 11)),
                            Text(widget.product.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('Size ${widget.selectedSize}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── "Original" compare label ────────────────────────────────────
          if (_showOriginal)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.44,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Original',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),

          // ── Frame scrub progress ────────────────────────────────────────
          Positioned(
            bottom: 120,
            left: 24,
            right: 24,
            child: AnimatedBuilder(
              animation: _aniCtrl,
              builder: (_, __) {
                final progress = _resultFrames.isEmpty
                    ? 0.0
                    : _currentFrameIndex / (_resultFrames.length - 1);
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _hintChip(Icons.swipe, 'Swipe to scrub'),
                        const SizedBox(width: 8),
                        _hintChip(Icons.touch_app, 'Hold to compare'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Bottom controls ─────────────────────────────────────────────
          Positioned(
            bottom: 28,
            left: 20,
            right: 20,
            child: Row(
              children: [
                // Play / Pause
                GestureDetector(
                  onTap: _togglePlayback,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Done
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 6,
                      shadowColor:
                          AppColors.primaryRed.withOpacity(0.4),
                    ),
                    child: const Text('DONE',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hintChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white60, size: 13),
          const SizedBox(width: 5),
          Text(text,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}
