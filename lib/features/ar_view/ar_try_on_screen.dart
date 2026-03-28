import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as dart_math;
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import 'ar_result_screen.dart';

/// Stages of the VTON flow
enum _Stage {
  camera,      // Live camera — user positions themselves
  processing,  // Uploaded + waiting for AI result
}

/// AR Try-On screen powered by FASHN.AI Virtual Try-On.
///
/// Flow:
///   1. Live rear camera feed (user frames themselves)
///   2. User taps "Try On" → photo captured → uploaded to Firebase Storage
///   3. `initiateTryOn` Cloud Function called with user photo + product image URLs
///   4. Poll `getTryOnStatus` every 3 s until completed / failed (max 120 s)
///   5. Show result image with share / retry options
class ARTryOnScreen extends StatefulWidget {
  final Product product;
  final String initialSize;

  const ARTryOnScreen({
    super.key,
    required this.product,
    this.initialSize = 'M',
  });

  @override
  State<ARTryOnScreen> createState() => _ARTryOnScreenState();
}

class _ARTryOnScreenState extends State<ARTryOnScreen>
    with WidgetsBindingObserver {
  // ── Camera ──────────────────────────────────────────────────────────────
  CameraController? _cameraController;
  bool _isCameraReady = false;

  // ── UI State ────────────────────────────────────────────────────────────
  _Stage _stage = _Stage.camera;
  String _statusMessage = '';
  double _progressValue = 0.0; // 0.0 – 1.0
  String? _errorMessage;
  String _selectedSize = 'M';

  // ── Polling timer (tracks SSE progress animation) ──────────────────────
  Timer? _pollTimer;

  // IDM-VTON HF space — fn_index 0 = /tryon endpoint
  // OOTDiffusion HF space — process_hd = Full Body Try-On
  static final String _hfSpaceUrl = 'https://levihsu-ootdiffusion.hf.space';

  // ── HuggingFace Token ────────────────────────────────────────────────────
  // ZeroGPU has a small daily anonymous quota. Adding a FREE HF token gives
  // you much higher quota (enough for dozens of try-ons per day).
  // 1. Sign up free: https://huggingface.co/join
  // 2. Create a "Read" token: https://huggingface.co/settings/tokens
  // 3. Paste it below:
  // static const String _hfToken = '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'; // e.g. 'hf_xxxxxxxxxxxxxxxxxxxx'
  static const String _hfToken = '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'; // e.g. 'hf_xxxxxxxxxxxxxxxxxxxx'

  /// Returns headers with Authorization if _hfToken is set, else basic headers.
  Map<String, String> get _joinHeaders => {
    'Content-Type': 'application/json',
    if (_hfToken.isNotEmpty) 'Authorization': 'Bearer $_hfToken',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedSize = widget.initialSize;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _cameraController?.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cc = _cameraController;
    if (cc == null || !cc.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      cc.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  // ── Camera init ──────────────────────────────────────────────────────────

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _setError('No camera found on this device.');
        return;
      }
      final cam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        cam,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) { controller.dispose(); return; }
      _cameraController = controller;
      setState(() => _isCameraReady = true);
    } catch (e) {
      _setError('Camera failed: $e');
    }
  }

  // ── VTON Flow ────────────────────────────────────────────────────────────

  Future<void> _startTryOn() async {
    if (!_isCameraReady || _cameraController == null) return;

    setState(() {
      _stage = _Stage.processing;
      _progressValue = 0.0;
      _statusMessage = 'Capturing photo...';
      _errorMessage = null;
    });

    try {
      // 1. Capture photo
      final xFile = await _cameraController!.takePicture();
      _setProgress(0.15, 'Processing photo...');
      final rawBytes = await xFile.readAsBytes();
      final imageBytes = await _fixRotation(rawBytes);

      // 2. Download and upload garment image
      _setProgress(0.20, 'Uploading product image to AI model...');
      final garmentRes = await http.get(
        Uri.parse(widget.product.imageUrl),
      ).timeout(const Duration(seconds: 20));
      if (garmentRes.statusCode != 200) {
        throw Exception('Could not download product image (${garmentRes.statusCode}).');
      }
      final garmentPath = await _uploadToGradio(garmentRes.bodyBytes, 'garment.jpg');

      final category = _inferCategory(widget.product);
      final garmentDesc = category == 'bottoms'
          ? 'lower body clothing'
          : category == 'one-pieces'
              ? 'full body clothing'
              : 'upper body clothing';

      // 3. Upload user photo
      _setProgress(0.35, 'Uploading your photo...');
      final humanPath = await _uploadToGradio(imageBytes, 'human.jpg');

      _setProgress(0.45, 'Generating virtual try-on (may take 1–2 mins)...');

      // Progress animation while waiting
      final startTime = DateTime.now();
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (!mounted) return;
        final elapsed = DateTime.now().difference(startTime).inSeconds;
        final progress = (0.45 + (elapsed / 120) * 0.50).clamp(0.45, 0.95);
        _setProgress(progress, 'AI is fitting the outfit… Please wait.');
      });

      // 4. Process
      final resultUrl = await _processSingleVtonFuture(humanPath, garmentPath, garmentDesc);
      _pollTimer?.cancel();

      if (resultUrl == null) {
        _setError(
            'AI processing failed.\n\nTips:\n• Full body must be visible\n• Stand 1.5–2 m from camera\n• Good lighting, plain background');
        return;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ARResultScreen(
              imageUrl: resultUrl,
              originalImageBytes: imageBytes,
            ),
          ),
        );
      }
    } catch (e) {
      _pollTimer?.cancel();
      debugPrint('[VTON] Error: $e');
      _setError('Something went wrong. Please try again.\n${e.toString().split("\n").first}');
    }
  }

  Future<String?> _processSingleVtonFuture(String humanPath, String garmentPath, String garmentDesc) async {
    final sessionHash = _generateSessionHash();
    try {
      final int fnIndex = await _resolveFnIndex();
      debugPrint('[VTON] using fn_index=$fnIndex');

      final humanFileData = _makeFileData(humanPath, 'human.jpg');
      final garmentFileData = _makeFileData(garmentPath, 'garment.jpg');

      final joinRes = await http.post(
        Uri.parse('$_hfSpaceUrl/queue/join'),
        headers: _joinHeaders,
        body: jsonEncode({
          'data': [
            humanFileData,   // 0: vton_img (Plain FileData for OOTDiffusion HD)
            garmentFileData, // 1: garm_img (FileData)
            1,               // 2: n_samples
            20,              // 3: n_steps
            2.0,             // 4: image_scale
            -1,              // 5: seed
          ],
          'event_data': null,
          'fn_index': fnIndex,
          'trigger_id': fnIndex + 6,
          'session_hash': sessionHash,
        }),
      );

      if (joinRes.statusCode != 200) return null;
      final joinData = jsonDecode(joinRes.body);
      if (joinData['event_id'] == null) return null;

      return await _listenForResultFuture(sessionHash);
    } catch (e) {
      debugPrint('[VTON] Single error: $e');
      return null;
    }
  }

  Future<int> _resolveFnIndex() async {
    try {
      final res = await http.get(
        Uri.parse('$_hfSpaceUrl/config'),
        headers: _joinHeaders,
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return 0;

      final config = jsonDecode(res.body) as Map<String, dynamic>;
      final deps = config['dependencies'] as List<dynamic>?;

      if (deps != null) {
        // Priority 1: Match by known endpoint name
        for (int i = 0; i < deps.length; i++) {
          final dep = deps[i] as Map<String, dynamic>?;
          final apiName = dep?['api_name'] as String?;
          if (apiName == 'process_hd' || apiName == '/process_hd' || 
              apiName == 'tryon' || apiName == '/tryon') {
            return i;
          }
        }

        // Priority 2: Fallback by expected input count (6 for OOTDiffusion HD)
        for (int i = 0; i < deps.length; i++) {
          final dep = deps[i] as Map<String, dynamic>?;
          final inputs = dep?['inputs'] as List?;
          if (inputs != null && inputs.length == 6) {
            return i;
          }
        }
      }
    } catch (e) {
      debugPrint('[VTON] /config lookup failed: $e');
    }
    return 0; // Default fallback
  }

  Future<String?> _listenForResultFuture(String sessionHash) async {
    final deadline = DateTime.now().add(const Duration(minutes: 3));
    final client = http.Client();
    try {
      final uri = Uri.parse('$_hfSpaceUrl/queue/data?session_hash=$sessionHash');
      final request = http.Request('GET', uri)
        ..headers['Accept'] = 'text/event-stream'
        ..headers['Cache-Control'] = 'no-cache';

      final response = await client.send(request).timeout(const Duration(minutes: 3));
      String buffer = '';

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        if (DateTime.now().isAfter(deadline)) break;
        buffer += chunk;

        while (buffer.contains('\n\n')) {
          final idx = buffer.indexOf('\n\n');
          final block = buffer.substring(0, idx);
          buffer = buffer.substring(idx + 2);

          String? dataLine;
          for (final line in block.split('\n')) {
            if (line.startsWith('data:')) dataLine = line;
          }
          if (dataLine == null) continue;

          Map<String, dynamic> event;
          try {
            event = jsonDecode(dataLine.substring(5).trim()) as Map<String, dynamic>;
          } catch (_) { continue; }

          final msg = event['msg'] as String?;
          debugPrint('[VTON] SSE msg=$msg raw=${jsonEncode(event)}');
          
          if (msg == 'process_completed') {
            final success = event['success'] as bool? ?? true;
            if (!success) {
               final hfError = event['output']?['error'] as String?;
               debugPrint('HF Error: $hfError');
               return null;
            }
            return _extractOutputUrl(event);
          } else if (msg == 'process_errored' || msg == 'queue_full') {
            return null;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('[VTON] SSE error: $e');
      return null;
    } finally {
      client.close();
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _setProgress(double value, String message) {
    if (!mounted) return;
    setState(() {
      _progressValue = value;
      _statusMessage = message;
    });
  }

  void _setError(String message) {
    _pollTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _stage = _Stage.camera;
      _errorMessage = message;
    });
  }

  /// Tries every known Gradio output structure to extract a usable image URL.
  /// OOTDiffusion returns a Gallery: data[0] = List<{image: FileData, caption}>
  String? _extractOutputUrl(Map<String, dynamic> event) {
    final output = event['output'];
    debugPrint('[VTON] event[output]: $output');

    if (output is Map) {
      final data = output['data'];
      debugPrint('[VTON] output[data]: $data');
      if (data is List && data.isNotEmpty) {
        return _deepSearchUrl(data);
      }
    }

    final topData = event['data'];
    if (topData is List && topData.isNotEmpty) {
      debugPrint('[VTON] event[data] (Gradio 4 style): $topData');
      return _deepSearchUrl(topData);
    }

    return null;
  }

  String? _deepSearchUrl(dynamic data) {
    if (data is String && data.isNotEmpty) return data;
    if (data is Map) return _urlFromRaw(data);
    if (data is List && data.isNotEmpty) {
      for (final item in data) {
        final result = _deepSearchUrl(item);
        if (result != null) return result;
      }
    }
    return null;
  }

  String? _urlFromRaw(dynamic raw) {
    if (raw is String && (raw.startsWith('http') || raw.contains('/tmp/gradio/'))) return raw;
    if (raw is Map) {
      // 1. Try 'image' nested field (common in Gallery items)
      if (raw.containsKey('image')) {
        final inner = _urlFromRaw(raw['image']);
        if (inner != null) return inner;
      }
      // 2. Try 'path' field (Gradio 4 FileData)
      final path = raw['path'] as String?;
      if (path != null && path.isNotEmpty) {
        // If path is absolute URL already, return it
        if (path.startsWith('http')) return path;
        return '$_hfSpaceUrl/file=$path';
      }
      // 3. Try 'url' field
      final url = raw['url'] as String?;
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  String _inferCategory(Product product) {
    final name = '${product.name} ${product.description}'.toLowerCase();
    if (name.contains('dress') || name.contains('jumpsuit') ||
        name.contains('suit')) return 'one-pieces';
    if (name.contains('pant') || name.contains('jeans') ||
        name.contains('skirt') || name.contains('short')) return 'bottoms';
    return 'tops'; // default
  }

  // ── HF API Helpers ───────────────────────────────────────────────────────

  /// Decodes the JPEG, applies EXIF orientation (rotates the pixels to match
  /// the EXIF tag), and re-encodes to JPEG. Without this, IDM-VTON sees the
  /// person lying sideways because the camera sensor captures in landscape.
  Future<Uint8List> _fixRotation(Uint8List rawBytes) async {
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) return rawBytes;
    final oriented = img.bakeOrientation(decoded);
    return Uint8List.fromList(img.encodeJpg(oriented, quality: 92));
  }

  Future<String> _uploadToGradio(List<int> bytes, String filename) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_hfSpaceUrl/upload'));
    if (_hfToken.isNotEmpty) request.headers['Authorization'] = 'Bearer $_hfToken';
    request.files.add(http.MultipartFile.fromBytes(
      'files',
      bytes,
      filename: filename,
    ));
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to upload $filename to AI server (HTTP ${response.statusCode})');
    }
    final respStr = await response.stream.bytesToString();
    debugPrint('[VTON] upload response for $filename: $respStr');
    final paths = jsonDecode(respStr) as List;
    final path = paths[0] as String;
    debugPrint('[VTON] upload path: $path');
    return path;
  }

  // Full Gradio FileData format — required by IDM-VTON (worked yesterday).
  Map<String, dynamic> _makeFileData(String path, String name) {
    return {
      'path': path,
      'url': '$_hfSpaceUrl/file=$path',
      'size': null,
      'orig_name': name,
      'mime_type': 'image/jpeg',
      'is_stream': false,
      'meta': {'_type': 'gradio.FileData'},
    };
  }

  String _generateSessionHash() {
    final chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = dart_math.Random();
    return List.generate(11, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── STAGE: Camera ────────────────────────────────────────────────
          if (_stage == _Stage.camera) _buildCameraStage(),

          // ── STAGE: Processing ────────────────────────────────────────────
          if (_stage == _Stage.processing) _buildProcessingStage(),

          // ── Common: Top close button ─────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: _circleButton(Icons.close, () => Navigator.pop(context)),
          ),

          // ── Error snackbar-style banner ──────────────────────────────────
          if (_errorMessage != null)
            Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                      onPressed: () =>
                          setState(() => _errorMessage = null),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Camera stage ─────────────────────────────────────────────────────────

  Widget _buildCameraStage() {
    return Stack(
      children: [
        // Camera feed
        if (_isCameraReady && _cameraController != null)
          Positioned.fill(child: CameraPreview(_cameraController!))
        else
          const Center(
            child: CircularProgressIndicator(color: AppColors.primaryRed),
          ),

        // Guide silhouette overlay
        if (_isCameraReady)
          Positioned.fill(
            child: CustomPaint(painter: _SilhouettePainter()),
          ),

        // Instruction banner
        if (_isCameraReady)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 20,
            right: 20,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🧍 Stand upright, face the camera, full body visible — then tap "Try On" & move for 360°',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),

        // Product thumbnail in corner
        if (_isCameraReady && widget.product.imageUrl.isNotEmpty)
          Positioned(
            bottom: 160,
            right: 16,
            child: Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white30, width: 1.5),
                color: Colors.black54,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Center(
                      child: Icon(Icons.checkroom,
                          color: Colors.white38, size: 32)),
                  errorWidget: (_, __, ___) => const Center(
                      child: Icon(Icons.checkroom,
                          color: Colors.white38, size: 32)),
                ),
              ),
            ),
          ),

        // Bottom controls
        Positioned(
          bottom: 32,
          left: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSizeRow(),
              const SizedBox(height: 16),
              // Main Try-On button
              GestureDetector(
                onTap: _isCameraReady ? _startTryOn : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryRed, Color(0xFFFF6B6B)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryRed.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome,
                          color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Try On with AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Processing stage ─────────────────────────────────────────────────────

  Widget _buildProcessingStage() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                builder: (_, val, child) =>
                    Transform.scale(scale: val, child: child),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryRed.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: AppColors.primaryRed, size: 52),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _statusMessage,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progressValue,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primaryRed),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${(_progressValue * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 32),
              const Text(
                'AI is generating your virtual try-on.\nThis usually takes 20–60 seconds.',
                style: TextStyle(color: Colors.white38, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }



  // ── Shared widgets ───────────────────────────────────────────────────────

  Widget _buildSizeRow() {
    final sizes = widget.product.availableSizes.isNotEmpty
        ? widget.product.availableSizes
        : ['S', 'M', 'L', 'XL'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: sizes.map((size) {
        final sel = _selectedSize == size;
        return GestureDetector(
          onTap: () => setState(() => _selectedSize = size),
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: sel ? AppColors.primaryRed : Colors.white24,
              shape: BoxShape.circle,
              border: Border.all(
                  color: sel ? AppColors.primaryRed : Colors.white38,
                  width: 1.5),
            ),
            child: Center(
              child: Text(size,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          sel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration:
            const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
} // <--- Added closing brace here

// ── Silhouette guide overlay ──────────────────────────────────────────────────

class _SilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final cx = size.width / 2;
    // Head oval
    final headR = size.width * 0.07;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, size.height * 0.14), width: headR * 2, height: headR * 2.4),
      paint,
    );
    // Body rect
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, size.height * 0.42),
          width: size.width * 0.42,
          height: size.height * 0.38,
        ),
        const Radius.circular(12),
      ),
      paint,
    );
    // Legs
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - size.width * 0.18, size.height * 0.62,
            size.width * 0.15, size.height * 0.27),
        const Radius.circular(8),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + size.width * 0.03, size.height * 0.62,
            size.width * 0.15, size.height * 0.27),
        const Radius.circular(8),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
