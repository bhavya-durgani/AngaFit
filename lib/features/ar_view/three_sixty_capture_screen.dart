import 'dart:async';
import 'dart:convert';
import 'dart:math' as dart_math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumb;

import '../../data/dummy_data.dart';
import 'three_sixty_result_screen.dart';

// ─── Isolate helper (keeps UI thread free) ────────────────────────────────────
Uint8List _fixRotationIsolate(Uint8List rawBytes) {
  final decoded = img.decodeImage(rawBytes);
  if (decoded == null) return rawBytes;
  final oriented = img.bakeOrientation(decoded);
  return Uint8List.fromList(img.encodeJpg(oriented, quality: 90));
}

// ─── Capture phase ────────────────────────────────────────────────────────────
enum _Phase {
  waiting,
  countdown,
  recording,
  extracting,
  reviewing,
  processing,
  failed,
}

class ThreeSixtyCaptureScreen extends StatefulWidget {
  final Product product;
  final String selectedSize;
  final String? garmentImageUrl;

  const ThreeSixtyCaptureScreen({
    super.key,
    required this.product,
    required this.selectedSize,
    this.garmentImageUrl,
  });

  @override
  State<ThreeSixtyCaptureScreen> createState() =>
      _ThreeSixtyCaptureScreenState();
}

class _ThreeSixtyCaptureScreenState extends State<ThreeSixtyCaptureScreen>
    with TickerProviderStateMixin {
  // ── Camera ──────────────────────────────────────────────────────────────
  CameraController? _cameraController;
  bool _isCameraReady = false;

  // ── Phase ───────────────────────────────────────────────────────────────
  _Phase _phase = _Phase.waiting;

  // ── Countdown / Recording ────────────────────────────────────────────────
  int _countdown = 3;
  int _recordingSecsLeft = 5;
  Timer? _recordingTimer;

  // ── Frames / Results ────────────────────────────────────────────────────
  static const int _targetFrameCount = 8;
  static const int _rawExtractCount = 16;
  static const int _concurrencyLimit = 2;

  List<Uint8List> _frames = [];
  List<bool?> _frameStatus = []; // null=pending, true=done, false=failed
  List<String?> _resultUrls = [];
  int _processedCount = 0;
  String? _processError;
  bool _isProcessing = false;
  bool _quotaExhausted = false;

  // ── Animations ──────────────────────────────────────────────────────────
  late AnimationController _pulseAnim;
  late AnimationController _rotateGuideAnim;

  // ── VTON API ────────────────────────────────────────────────────────────
  Uint8List? _garmentBytes;

  /// FIX: Track whether garment download is still in progress so we can
  /// disable the Start button until the bytes are ready.
  bool _garmentLoading = false;

  final String _hfSpaceUrl = 'https://levihsu-ootdiffusion.hf.space';
  final List<String> _hfTokens = [
    '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',
    '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',
    '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',
    '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',
  ];

  /// FIX: Each concurrent frame gets its own token index to avoid
  /// shared-state corruption when two frames rotate tokens simultaneously.
  int _globalTokenIndex = 0;
  final _tokenLock = _AsyncMutex();

  final Map<String, String> _jsonHeaders = {'Content-Type': 'application/json'};

  // ── Ready guard ──────────────────────────────────────────────────────────
  /// The Start button is only active when both the camera AND the garment
  /// image are ready. This prevents the "Garment image not ready" silent fail.
  bool get _canStart =>
      _isCameraReady &&
      _cameraController != null &&
      !_garmentLoading &&
      (widget.garmentImageUrl == null || _garmentBytes != null);

  // ────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initCamera();
    if (widget.garmentImageUrl != null) {
      // FIX: track loading state so the UI can block the start button.
      _garmentLoading = true;
      _downloadGarment(widget.garmentImageUrl!);
    }
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _rotateGuideAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  // ── Camera ──────────────────────────────────────────────────────────────
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _cameraController!.initialize();
      await _cameraController!
          .lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (mounted) setState(() => _isCameraReady = true);
    } catch (e) {
      debugPrint('[360] Camera init err: $e');
    }
  }

  Future<void> _downloadGarment(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _garmentBytes = res.bodyBytes;
          _garmentLoading = false;
        });
      } else {
        if (mounted) setState(() => _garmentLoading = false);
        debugPrint('[360] Garment DL bad status: ${res.statusCode}');
      }
    } catch (e) {
      if (mounted) setState(() => _garmentLoading = false);
      debugPrint('[360] Garment DL failed: $e');
    }
  }

  // ── Recording flow ───────────────────────────────────────────────────────
  void _startCountdown() {
    if (!_canStart) return;
    setState(() {
      _phase = _Phase.countdown;
      _countdown = 3;
    });
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        t.cancel();
        _beginVideoRecording();
      }
    });
  }

  Future<void> _beginVideoRecording() async {
    if (_cameraController == null || !mounted) return;
    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _phase = _Phase.recording;
        _recordingSecsLeft = 5;
      });
      _recordingTimer =
          Timer.periodic(const Duration(seconds: 1), (t) async {
        if (!mounted) {
          t.cancel();
          return;
        }
        if (_recordingSecsLeft > 1) {
          setState(() => _recordingSecsLeft--);
        } else {
          t.cancel();
          await _finishRecording();
        }
      });
    } catch (e) {
      debugPrint('[360] Record start err: $e');
      setState(() {
        _phase = _Phase.failed;
        _processError = 'Could not start recording: $e';
      });
    }
  }

  Future<void> _finishRecording() async {
    if (!mounted) return;
    setState(() => _phase = _Phase.extracting);

    XFile? videoFile;
    try {
      videoFile = await _cameraController!.stopVideoRecording();
    } catch (e) {
      setState(() {
        _phase = _Phase.failed;
        _processError = 'Failed to save video: $e';
      });
      return;
    }

    // ── Extract raw frames at evenly-spaced timestamps ─────────────────────
    // FIX: offload rotation fix to an isolate so the UI stays responsive.
    final List<Uint8List> rawFrames = [];
    for (int i = 0; i < _rawExtractCount; i++) {
      final timeMs = (i * 4800 ~/ (_rawExtractCount - 1));
      try {
        final data = await video_thumb.VideoThumbnail.thumbnailData(
          video: videoFile.path,
          imageFormat: video_thumb.ImageFormat.JPEG,
          maxWidth: 576,
          maxHeight: 1024,
          quality: 90,
          timeMs: timeMs,
        );
        if (data != null && data.isNotEmpty) {
          // FIX: use compute() isolate instead of blocking the main thread.
          final fixed = await compute(_fixRotationIsolate, data);
          rawFrames.add(fixed);
        }
      } catch (e) {
        debugPrint('[360] Frame $i extract err: $e');
      }
    }

    if (rawFrames.isEmpty) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.failed;
        _processError =
            'Could not extract frames from the video.\nPlease ensure storage permission is granted and try again.';
      });
      return;
    }

    final selectedFrames = await _selectBestFrames(rawFrames);

    if (!mounted) return;
    setState(() {
      _frames = selectedFrames;
      _frameStatus = List.filled(selectedFrames.length, null);
      _resultUrls = List.filled(selectedFrames.length, null);
      _processedCount = 0;
      _phase = _Phase.reviewing;
    });
  }

  // ── Frame Scoring ────────────────────────────────────────────────────────
  Future<List<Uint8List>> _selectBestFrames(List<Uint8List> rawFrames) async {
    if (rawFrames.length <= _targetFrameCount) return rawFrames;

    final scored = <_FrameScore>[];
    for (int i = 0; i < rawFrames.length; i++) {
      final score = await compute(_scoreFrameIsolate, _FrameInput(rawFrames[i], i));
      scored.add(score);
    }

    scored.sort((a, b) => a.index.compareTo(b.index));

    final int segments = _targetFrameCount;
    final selected = <_FrameScore>[];
    final usedIndices = <int>{};

    final double segmentSize = (rawFrames.length - 1) / (segments - 1);

    for (int s = 0; s < segments; s++) {
      final double targetPos = s * segmentSize;
      _FrameScore? best;
      double bestDistance = double.infinity;

      for (final fs in scored) {
        if (usedIndices.contains(fs.index)) continue;
        final double dist = (fs.index - targetPos).abs();
        if (dist < bestDistance ||
            (dist == bestDistance &&
                (best == null || fs.score > best.score))) {
          bestDistance = dist;
          best = fs;
        }
      }

      if (best != null) {
        selected.add(best);
        usedIndices.add(best.index);
      }
    }

    selected.sort((a, b) => a.index.compareTo(b.index));
    return selected.map((e) => e.bytes).toList();
  }

  // ── Processing Flow ──────────────────────────────────────────────────────
  Future<void> _startProcessing() async {
    setState(() {
      _phase = _Phase.processing;
      _isProcessing = true;
      _quotaExhausted = false;
      _processError = null;
    });

    int currentIndex = 0;

    while (currentIndex < _frames.length && mounted) {
      final batch = <Future>[];
      for (int i = 0;
          i < _concurrencyLimit && currentIndex < _frames.length;
          i++) {
        // FIX: capture currentIndex in a local variable to avoid closure issue.
        final frameIndex = currentIndex;
        batch.add(_processSingleFrame(frameIndex));
        currentIndex++;
      }
      await Future.wait(batch);

      if (!_isProcessing || !mounted) return;
      if (_quotaExhausted) break;
    }

    if (!mounted) return;

    final validFrames = <Uint8List>[];
    final validUrls = <String?>[];
    for (int i = 0; i < _frames.length; i++) {
      if (_resultUrls[i] != null) {
        validFrames.add(_frames[i]);
        validUrls.add(_resultUrls[i]);
      }
    }

    if (validUrls.isEmpty) {
      setState(() {
        _phase = _Phase.failed;
        _isProcessing = false;
        _processError = 'All frames failed — the AI couldn\'t process any image.'
            '\n\n• Keep full body in frame\n• Stand 1.5–2 m from camera\n• Good lighting, plain background';
      });
    } else {
      setState(() => _isProcessing = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ThreeSixtyResultScreen(
            capturedImages: List.unmodifiable(validFrames),
            resultUrls: List.unmodifiable(validUrls),
            product: widget.product,
            selectedSize: widget.selectedSize,
          ),
        ),
      );
    }
  }

  void _onRetake() {
    setState(() {
      _phase = _Phase.waiting;
      _isProcessing = false;
      _processError = null;
      _frames = [];
      _frameStatus = [];
      _resultUrls = [];
      _processedCount = 0;
    });
  }

  // ── VTON API ─────────────────────────────────────────────────────────────

  /// FIX: Each frame gets its own token index snapshot so concurrent frames
  /// don't corrupt each other when rotating tokens.
  Future<int> _acquireTokenIndex() async {
    return await _tokenLock.run(() async => _globalTokenIndex);
  }

  Future<void> _rotateTokenGlobal() async {
    await _tokenLock.run(() async {
      _globalTokenIndex = (_globalTokenIndex + 1) % _hfTokens.length;
    });
  }

  Future<void> _processSingleFrame(int i) async {
    String? resultUrl;
    String? errorMsg;

    // FIX: Each frame independently walks through available tokens.
    int localTokenIndex = await _acquireTokenIndex();

    for (var attempt = 0; attempt < _hfTokens.length; attempt++) {
      final token = _hfTokens[localTokenIndex % _hfTokens.length];
      try {
        final result = await _callVtonApi(i, _frames[i], token);
        resultUrl = result.url;
        errorMsg = result.error;
      } catch (e) {
        resultUrl = null;
        errorMsg = 'Network error: $e';
      }

      final isQuota = errorMsg != null &&
          (errorMsg.toLowerCase().contains('quota') ||
              errorMsg.toLowerCase().contains('zerogpu') ||
              errorMsg.toLowerCase().contains('daily'));

      if (isQuota) {
        if (localTokenIndex < _hfTokens.length - 1) {
          localTokenIndex++;
          await _rotateTokenGlobal();
          continue;
        } else {
          _quotaExhausted = true;
          errorMsg =
              'Daily AI quota reached for all configured tokens.\nPlease wait for reset or add another free Hugging Face token.';
        }
      }
      break;
    }

    if (mounted) {
      setState(() {
        _resultUrls[i] = resultUrl;
        _frameStatus[i] = resultUrl != null;
        _processedCount++;
        if (resultUrl == null && errorMsg != null) {
          _processError = errorMsg;
        }
      });
    }
  }

  Future<({String? url, String? error})> _callVtonApi(
      int index, Uint8List imageBytes, String token) async {
    if (_garmentBytes == null) {
      return (url: null, error: 'Garment image not ready. Please restart.');
    }
    final garmentDesc = _garmentDesc(widget.product);
    try {
      // Upload human first, then garment — order matches the data[] array below.
      final humanPath =
          await _uploadToGradio(imageBytes, 'human_$index.jpg', token);
      debugPrint('[360 VTON] humanPath: $humanPath');

      final garmentPath =
          await _uploadToGradio(_garmentBytes!, 'garment_$index.jpg', token);
      debugPrint('[360 VTON] garmentPath: $garmentPath');

      // ── Discover the correct fn_index from the live /info endpoint ─────────
      // IDM-VTON exposes a named endpoint "tryon". We look it up dynamically
      // so a space update never silently breaks the integration.
      final int fnIndex = await _resolveFnIndex(token);
      debugPrint('[360 VTON] using fn_index=$fnIndex');

      final sessionHash = _generateSessionHash();

      // ── Build the data payload ─────────────────────────────────────────────
      final humanFileData = _makeFileData(humanPath, 'human_$index.jpg');
      final garmentFileData = _makeFileData(garmentPath, 'garment_$index.jpg');

      final payload = {
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
      };

      debugPrint('[360 VTON] queue/join payload: ${jsonEncode(payload)}');

      final joinRes = await http.post(
        Uri.parse('$_hfSpaceUrl/queue/join'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      debugPrint('[360 VTON] join status: ${joinRes.statusCode}');
      debugPrint('[360 VTON] join body: ${joinRes.body}');

      if (joinRes.statusCode != 200) {
        return (
          url: null,
          error: 'Queue join failed (HTTP ${joinRes.statusCode}): ${joinRes.body}'
        );
      }

      final joinData = jsonDecode(joinRes.body) as Map<String, dynamic>;
      if (joinData['event_id'] == null) {
        return (
          url: null,
          error: 'No queue slot — AI server overloaded. Retry in a moment.'
        );
      }
      return _listenForResult(sessionHash, token);
    } catch (e, st) {
      debugPrint('[360 VTON] _callVtonApi exception: $e\n$st');
      return (
        url: null,
        error: 'Network error: ${e.toString().split("\n").first}'
      );
    }
  }

  /// Fetches the space /config endpoint and returns the fn_index for the
  /// target inference endpoint. Falls back to 0 if lookup fails.
  Future<int> _resolveFnIndex(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$_hfSpaceUrl/config'),
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
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
            debugPrint('[360 VTON] Found fn_index=$i matching $apiName');
            return i;
          }
        }

        // Priority 2: Fallback by expected input count (6 for OOTDiffusion HD)
        for (int i = 0; i < deps.length; i++) {
          final dep = deps[i] as Map<String, dynamic>?;
          final inputs = dep?['inputs'] as List?;
          if (inputs != null && inputs.length == 6) {
            debugPrint('[360 VTON] inferred fn_index=$i from 6 inputs count');
            return i;
          }
        }
      }
    } catch (e) {
      debugPrint('[360 VTON] /config lookup failed: $e — using fn_index=0');
    }
    return 0;
  }

  Future<({String? url, String? error})> _listenForResult(
      String sessionHash, String token) async {
    final deadline = DateTime.now().add(const Duration(minutes: 4));
    final client = http.Client();
    try {
      final req = http.Request(
          'GET',
          Uri.parse(
              '$_hfSpaceUrl/queue/data?session_hash=$sessionHash'))
        ..headers['Accept'] = 'text/event-stream'
        ..headers['Cache-Control'] = 'no-cache';
      if (token.isNotEmpty) req.headers['Authorization'] = 'Bearer $token';

      final resp = await client.send(req).timeout(const Duration(minutes: 4));
      String buf = '';

      await for (final chunk
          in resp.stream.transform(const Utf8Decoder())) {
        if (DateTime.now().isAfter(deadline) || !mounted) {
          return (url: null, error: 'Timed out — please retake.');
        }
        buf += chunk;
        while (buf.contains('\n\n')) {
          final idx = buf.indexOf('\n\n');
          final block = buf.substring(0, idx);
          buf = buf.substring(idx + 2);

          String? dataLine;
          for (final line in block.split('\n')) {
            if (line.startsWith('data:')) dataLine = line;
          }
          if (dataLine == null) continue;

          Map<String, dynamic> event;
          try {
            event =
                jsonDecode(dataLine.substring(5).trim()) as Map<String, dynamic>;
          } catch (_) {
            continue;
          }

          final msg = event['msg'] as String?;
          // Print full event — essential for diagnosing schema mismatches.
          debugPrint('[360 VTON] SSE msg=$msg  raw=${jsonEncode(event)}');

          if (msg == 'process_completed') {
            final success = event['success'] as bool? ?? true;
            if (!success) {
              final err = _extractError(event);
              debugPrint('[360 VTON] process_completed failed: $err');
              return (url: null, error: err);
            }
            final url = _extractOutputUrl(event);
            debugPrint('[360 VTON] extracted url=$url');
            return url != null
                ? (url: url, error: null)
                : (
                    url: null,
                    error:
                        'AI returned empty result. Keep full body in frame.'
                  );
          } else if (msg == 'process_errored') {
            return (url: null, error: _extractError(event));
          } else if (msg == 'queue_full') {
            return (
              url: null,
              error: 'AI queue is full — retry in a moment.'
            );
          }
        }
      }
      return (url: null, error: 'Connection closed before result — retry.');
    } catch (e) {
      return (
        url: null,
        error:
            'Connection error: ${e.toString().split("\n").first}'
      );
    } finally {
      client.close();
    }
  }

  String _extractError(Map<String, dynamic> event) {
    String? raw;
    final output = event['output'];
    if (output is Map) raw = output['error'] as String?;
    raw ??= event['error'] as String?;
    if (raw == null) {
      final tb = event['traceback'] as String?;
      if (tb != null && tb.isNotEmpty) {
        raw = tb.split('\n').where((l) => l.trim().isNotEmpty).last.trim();
      }
    }
    return _mapError(raw ?? '');
  }

  String _mapError(String raw) {
    final l = raw.toLowerCase();
    if (l.contains('zerogpu') || l.contains('quota') || l.contains('daily')) {
      return 'Daily AI quota reached for all configured tokens.\nPlease wait for reset or add another free Hugging Face token.';
    }
    if (l.contains('no person') || l.contains('not detected')) {
      return 'No person detected.\n• Move back so full body fits\n• Arms away from sides\n• Good lighting';
    }
    if (l.contains('openpose') ||
        l.contains('pose') ||
        l.contains('keypoint')) {
      return 'Pose not detected.\n• Stand upright\n• Plain background\n• Arms visible';
    }
    if (l.contains('timeout') || l.contains('time out')) {
      return 'Processing timed out — server busy. Please retake.';
    }
    if (l.contains('cuda') ||
        l.contains('gpu') ||
        l.contains('memory')) {
      return 'AI server out of memory — temporary. Please retry.';
    }
    if (raw.isNotEmpty && raw.length < 160) {
      return '$raw\n\nRetake with better lighting.';
    }
    return 'AI processing failed.\n• Full body in frame\n• 1.5–2 m from camera\n• Good lighting';
  }

  Future<String> _uploadToGradio(
      List<int> bytes, String filename, String token) async {
    final req =
        http.MultipartRequest('POST', Uri.parse('$_hfSpaceUrl/upload'));
    if (token.isNotEmpty) req.headers['Authorization'] = 'Bearer $token';
    req.files.add(
        http.MultipartFile.fromBytes('files', bytes, filename: filename));
    final resp = await req.send();
    if (resp.statusCode != 200) {
      throw Exception('Upload failed ($filename): HTTP ${resp.statusCode}');
    }
    final body = await resp.stream.bytesToString();
    debugPrint('[360 VTON] upload response for $filename: $body');
    return (jsonDecode(body) as List)[0] as String;
  }

  Map<String, dynamic> _makeFileData(String path, String name) => {
        'path': path,
        'url': '$_hfSpaceUrl/file=$path',
        'size': null,
        'orig_name': name,
        'mime_type': 'image/jpeg',
        'is_stream': false,
        'meta': {'_type': 'gradio.FileData'},
      };

  String _generateSessionHash() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = dart_math.Random();
    return List.generate(11, (_) => chars[r.nextInt(chars.length)]).join();
  }

  /// FIX: Robust output extraction that handles all known Gradio response shapes.
  /// Logs the raw structure so schema changes are immediately visible in debug.
  String? _extractOutputUrl(Map<String, dynamic> event) {
    final output = event['output'];
    debugPrint('[360 VTON] raw output: $output');

    List<dynamic>? dataList;

    if (output is Map) {
      final d = output['data'];
      if (d is List) dataList = d;
    }

    // Gradio 4.x sometimes puts data at the top level
    if (dataList == null) {
      final d = event['data'];
      if (d is List) dataList = d;
    }

    if (dataList == null || dataList.isEmpty) return null;
    debugPrint('[360 VTON] dataList[0]: ${dataList[0]}');

    final first = dataList[0];

    // Shape A: data[0] = [ {image: FileData, caption: ...} ]  — Gallery
    if (first is List && first.isNotEmpty) {
      final item = first[0];
      if (item is Map) {
        // Try nested image field first
        final imgField = item['image'];
        final url = _urlFromRaw(imgField) ?? _urlFromRaw(item);
        if (url != null) return url;
      }
    }

    // Shape B: data[0] = {image: FileData} — single image map
    if (first is Map) {
      final imgField = first['image'];
      final url = _urlFromRaw(imgField) ?? _urlFromRaw(first);
      if (url != null) return url;
    }

    // Shape C: data[0] = "https://..." — plain string
    return _urlFromRaw(first);
  }

  String? _urlFromRaw(dynamic raw) {
    if (raw is String && raw.isNotEmpty) return raw;
    if (raw is Map) {
      // Prefer path-based URL — Gradio often returns url: null
      final path = raw['path'] as String?;
      if (path != null && path.isNotEmpty) {
        return '$_hfSpaceUrl/file=$path';
      }
      final url = raw['url'] as String?;
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  String _garmentDesc(Product product) {
    final name =
        '${product.name} ${product.description}'.toLowerCase();
    if (name.contains('dress') ||
        name.contains('jumpsuit') ||
        name.contains('suit')) {
      return 'full body clothing';
    }
    if (name.contains('pant') ||
        name.contains('jeans') ||
        name.contains('skirt') ||
        name.contains('short')) {
      return 'lower body clothing';
    }
    return 'upper body clothing';
  }

  // ── Dispose ──────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _recordingTimer?.cancel();
    _cameraController?.dispose();
    _pulseAnim.dispose();
    _rotateGuideAnim.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isCameraReady && _cameraController != null)
            SizedBox.expand(child: CameraPreview(_cameraController!)),

          if (_phase == _Phase.waiting) _buildWaitingOverlay(),
          if (_phase == _Phase.countdown) _buildCountdownOverlay(),
          if (_phase == _Phase.recording) _buildRecordingOverlay(),
          if (_phase == _Phase.extracting) _buildExtracting(),
          if (_phase == _Phase.reviewing) _buildReviewOverlay(),
          if (_phase == _Phase.processing) _buildProcessingOverlay(),
          if (_phase == _Phase.failed) _buildFailedOverlay(),

          if (_phase != _Phase.processing && _phase != _Phase.reviewing)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: IconButton(
                icon:
                    const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
        ],
      ),
    );
  }

  // ── Phase Widgets ─────────────────────────────────────────────────────────

  Widget _buildWaitingOverlay() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('360° Video Try-On',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _rotateGuideAnim,
            builder: (_, __) {
              return Transform.rotate(
                angle: _rotateGuideAnim.value * 2 * 3.14159,
                child: Icon(Icons.rotate_right,
                    color: Colors.white.withOpacity(0.35), size: 120),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam, color: Colors.white, size: 36),
                SizedBox(height: 12),
                Text(
                  'Face the camera, tap Start, then slowly rotate your whole body in a full circle.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontSize: 14, height: 1.5),
                ),
                SizedBox(height: 8),
                Text(
                  '5 seconds • 8 frames captured',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // FIX: Show loading spinner while garment downloads; disable button
          // until both camera and garment are ready.
          if (_garmentLoading)
            Column(
              children: const [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 8),
                Text('Loading garment…',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            )
          else
            GestureDetector(
              onTap: _canStart ? _startCountdown : null,
              child: Opacity(
                opacity: _canStart ? 1.0 : 0.4,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    return Center(
      child: Text(
        '$_countdown',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 120,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black45, blurRadius: 20)],
        ),
      ),
    );
  }

  Widget _buildRecordingOverlay() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                            .withOpacity(0.4 + 0.6 * _pulseAnim.value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('REC  ${_recordingSecsLeft}s',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(bottom: 48),
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Slowly rotate your full body in a circle',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtracting() {
    return Container(
      color: Colors.black.withOpacity(0.88),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text('Selecting the best frames…',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.92),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Review Keyframes',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'If you are blurry or your arms are covering your waist, please retake. Otherwise, proceed to generate!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _frames.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _frames[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                            color: Colors.white.withOpacity(0.3)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _onRetake,
                      child: const Text('Retake',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: _startProcessing,
                      child: const Text('Generate 360°',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    final total = _frameStatus.length;
    final done = _processedCount;
    final progress = total == 0 ? 0.0 : done / total;

    return Container(
      color: Colors.black.withOpacity(0.92),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.3).animate(CurvedAnimation(
                  parent: _pulseAnim, curve: Curves.easeOut)),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context)
                            .primaryColor
                            .withOpacity(0.5),
                        blurRadius: 24)
                  ],
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'AI is generating your 360° try-on…',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '$done / $total frames processed',
              style:
                  const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: List.generate(_frameStatus.length, (i) {
                  final status = _frameStatus[i];
                  Color color;
                  IconData icon;
                  if (status == null) {
                    color = Colors.white24;
                    icon = Icons.hourglass_empty;
                  } else if (status) {
                    color = Colors.greenAccent;
                    icon = Icons.check_circle;
                  } else {
                    color = Colors.redAccent;
                    icon = Icons.error_outline;
                  }
                  return Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.15),
                      border: Border.all(color: color, width: 1.5),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This usually takes 30–90 seconds.\nPlease wait…',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white54, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.92),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 64),
              const SizedBox(height: 20),
              const Text('Processing Failed',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(
                _processError ?? 'An unknown error occurred.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: _onRetake,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Frame scoring — runs in an isolate ──────────────────────────────────────
class _FrameInput {
  final Uint8List bytes;
  final int index;
  _FrameInput(this.bytes, this.index);
}

_FrameScore _scoreFrameIsolate(_FrameInput input) {
  final image = img.decodeImage(input.bytes);
  if (image == null) return _FrameScore(input.bytes, input.index, 0.0);

  final pixels = image.getBytes();
  final int step = image.numChannels;

  double brightnessSum = 0;
  double varianceSum = 0;

  for (int i = 0; i < pixels.length; i += step) {
    final r = pixels[i];
    final g = (i + 1 < pixels.length) ? pixels[i + 1] : r;
    final b = (i + 2 < pixels.length) ? pixels[i + 2] : r;
    brightnessSum += (r + g + b) / 3.0;
  }

  final int pixelCount = pixels.length ~/ step;
  final avgBrightness =
      pixelCount > 0 ? brightnessSum / pixelCount : 0.0;

  double brightnessPenalty = 0.0;
  if (avgBrightness < 40) brightnessPenalty = 50.0;
  if (avgBrightness > 230) brightnessPenalty = 50.0;

  for (int i = 0; i < pixels.length - step; i += step) {
    final l1 = (pixels[i] +
            ((i + 1 < pixels.length) ? pixels[i + 1] : 0) +
            ((i + 2 < pixels.length) ? pixels[i + 2] : 0)) /
        3.0;
    final l2 = (pixels[i + step] +
            ((i + step + 1 < pixels.length) ? pixels[i + step + 1] : 0) +
            ((i + step + 2 < pixels.length)
                ? pixels[i + step + 2]
                : 0)) /
        3.0;
    varianceSum += (l1 - l2).abs();
  }

  final sharpness = pixelCount > 0 ? varianceSum / pixelCount : 0.0;
  return _FrameScore(input.bytes, input.index, sharpness - brightnessPenalty);
}

class _FrameScore {
  final Uint8List bytes;
  final int index;
  final double score;
  _FrameScore(this.bytes, this.index, this.score);
}

// ─── Minimal async mutex to protect shared token index ───────────────────────
class _AsyncMutex {
  Future<void> _last = Future.value();

  Future<T> run<T>(Future<T> Function() fn) {
    final next = _last.then((_) => fn());
    _last = next.then((_) {}, onError: (_) {});
    return next;
  }
}