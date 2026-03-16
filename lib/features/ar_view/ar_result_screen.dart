import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';

class ARResultScreen extends StatefulWidget {
  final String imageUrl;
  final Uint8List? originalImageBytes;

  const ARResultScreen({
    super.key,
    required this.imageUrl,
    this.originalImageBytes,
  });

  @override
  State<ARResultScreen> createState() => _ARResultScreenState();
}

class _ARResultScreenState extends State<ARResultScreen> with SingleTickerProviderStateMixin {
  bool _showOriginal = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Your Fit Result', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Subtle radial background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Color(0xFF222222), Colors.black],
              ),
            ),
          ),

          // Main Image Display
          GestureDetector(
            onLongPressStart: widget.originalImageBytes != null ? (_) => setState(() => _showOriginal = true) : null,
            onLongPressEnd: widget.originalImageBytes != null ? (_) => setState(() => _showOriginal = false) : null,
            child: SizedBox.expand(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: _showOriginal && widget.originalImageBytes != null
                    ? Image.memory(
                        widget.originalImageBytes!,
                        key: const ValueKey('original'),
                        fit: BoxFit.contain,
                      )
                    : FadeTransition(
                        key: const ValueKey('result'),
                        opacity: _fadeAnimation,
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(color: AppColors.primaryRed),
                          ),
                          errorWidget: (_, __, ___) => Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.broken_image, color: Colors.white38, size: 64),
                                SizedBox(height: 12),
                                Text('Could not load result image.', style: TextStyle(color: Colors.white54)),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Compare Indicator
          if (_showOriginal)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.45,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Original Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),

          // Interactive Hint
          if (widget.originalImageBytes != null)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.touch_app, color: Colors.white70, size: 16),
                      SizedBox(width: 8),
                      Text('Hold image to compare', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            
          // Bottom Controls (Glassmorphic)
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text('TRY ANOTHER', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Long-press the image to save it.'),
                                backgroundColor: Colors.black87,
                              ),
                            );
                          },
                          icon: const Icon(Icons.share, size: 20),
                          label: const Text('SHARE', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54, width: 1.5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                      ),
                    ],
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
