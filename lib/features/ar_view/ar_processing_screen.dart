import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as dart_math;
import '../../core/constants/app_colors.dart';
import 'ar_result_screen.dart';

class ARProcessingScreen extends StatefulWidget {
  final String userImageUrl;
  final String productImageUrl;
  final String category;

  const ARProcessingScreen({
    super.key,
    required this.userImageUrl,
    required this.productImageUrl,
    required this.category,
  });

  @override
  State<ARProcessingScreen> createState() => _ARProcessingScreenState();
}

class _ARProcessingScreenState extends State<ARProcessingScreen> {
  String _status = "Initializing...";
  Timer? _timer;
  String? _predictionId;
  String? _sessionHash;

  static const String _hfSpaceUrl = 'https://yisol-idm-vton.hf.space';
  int _pollCount = 0;
  static const int _maxPolls = 60;

  @override
  void initState() {
    super.initState();
    _startTryOn();
  }

  Future<void> _startTryOn() async {
    try {
      setState(() => _status = "Uploading to free AI model...");

      // Download images via HTTP
      final humanRes = await http.get(Uri.parse(widget.userImageUrl));
      final garmentRes = await http.get(Uri.parse(widget.productImageUrl));

      // Upload to HF
      final humanPath = await _uploadToGradio(humanRes.bodyBytes, 'human.jpg');
      final garmentPath = await _uploadToGradio(garmentRes.bodyBytes, 'garment.jpg');

      setState(() => _status = "Submitting to AI queue...");

      final garmentDesc = widget.category == 'bottoms'
          ? 'lower body clothing'
          : widget.category == 'one-pieces'
              ? 'full body clothing'
              : 'upper body clothing';

      final sessionHash = _generateSessionHash();
      final joinRes = await http.post(
        Uri.parse('$_hfSpaceUrl/queue/join'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': [
            {
              'background': _makeFileData(humanPath, 'human.jpg'),
              'layers': [],
              'composite': null,
            },
            _makeFileData(garmentPath, 'garment.jpg'),
            garmentDesc,
            true,
            false,
            30,
            42,
          ],
          'event_data': null,
          'fn_index': 2,
          'trigger_id': 6,
          'session_hash': sessionHash,
        }),
      );

      if (joinRes.statusCode != 200) {
        throw Exception('Failed to join AI queue');
      }

      final joinData = jsonDecode(joinRes.body);
      _predictionId = joinData['event_id'] as String?;
      _sessionHash = sessionHash;

      if (_predictionId != null && _sessionHash != null) {
        _startPolling();
      } else {
        _handleError("No prediction ID returned from server.");
      }
    } catch (e) {
      _handleError("Failed to start processing: $e");
    }
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _pollCount++;
      if (_pollCount > _maxPolls) {
        timer.cancel();
        _handleError("Try-On took too long. Please try again.");
        return;
      }

      try {
        setState(() => _status = "Waiting in AI queue...");

        final client = http.Client();
        if (_sessionHash == null) return;
        final uri = Uri.parse('$_hfSpaceUrl/queue/data?session_hash=$_sessionHash');
        final request = http.Request('GET', uri)..headers['Accept'] = 'text/event-stream';

        String status = 'processing';
        String? outputUrl;
        String? errorMsg;

        try {
          final response = await client.send(request).timeout(const Duration(seconds: 10));
          final stream = response.stream.transform(utf8.decoder);

          await for (final chunk in stream) {
            final blocks = chunk.split('\n\n');
            for (final block in blocks) {
              final dataLine = block.split('\n').cast<String?>().firstWhere(
                    (l) => l != null && l.startsWith('data:'),
                    orElse: () => null,
                  );
              if (dataLine == null) continue;
              try {
                final event = jsonDecode(dataLine.substring(5).trim());
                final msg = event['msg'];
                if (msg == 'process_completed') {
                  status = 'completed';
                  final rawOutput = (event['output']?['data'] as List?)?.firstOrNull;
                  if (rawOutput is String) {
                    outputUrl = rawOutput;
                  } else if (rawOutput is Map) {
                    outputUrl = rawOutput['url'] ??
                        (rawOutput['path'] != null ? '$_hfSpaceUrl/file=${rawOutput['path']}' : null);
                  }
                  break;
                } else if (msg == 'process_errored' || msg == 'queue_full') {
                  status = 'failed';
                  errorMsg = msg;
                  break;
                }
              } catch (_) {}
            }
            if (status != 'processing') break;
          }
        } catch (_) {} finally {
          client.close();
        }

        if (status == 'completed') {
          timer.cancel();
          if (outputUrl != null && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ARResultScreen(imageUrl: outputUrl!)),
            );
          } else {
            _handleError("AI returned no image.");
          }
        } else if (status == 'failed') {
          timer.cancel();
          _handleError("Generation failed: ${errorMsg ?? 'Unknown error'}");
        }
      } catch (e) {
        debugPrint("Polling error: $e");
      }
    });
  }

  void _handleError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red));
      Navigator.pop(context);
    }
  }

  // ── HF API Helpers ───────────────────────────────────────────────────────

  Future<String> _uploadToGradio(List<int> bytes, String filename) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_hfSpaceUrl/upload'));
    request.files.add(http.MultipartFile.fromBytes('files', bytes, filename: filename));
    final response = await request.send();
    if (response.statusCode != 200) throw Exception('Upload failed');
    final respStr = await response.stream.bytesToString();
    final paths = jsonDecode(respStr) as List;
    return paths[0] as String;
  }

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome,
                size: 80, color: AppColors.primaryRed),
            const SizedBox(height: 30),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: AppColors.primaryRed),
          ],
        ),
      ),
    );
  }
}
