import 'dart:async'; // For Timer (used in polling)
import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:http/http.dart' as http; // For HTTP API calls
import 'dart:math' as dart_math; // For random session hash generation
import '../../core/constants/app_colors.dart'; // App color constants
import 'ar_result_screen.dart'; // Screen to show final AR result

class ARProcessingScreen extends StatefulWidget {
  final String userImageUrl; // URL of user image
  final String productImageUrl; // URL of product image
  final String category; // Product category (top/bottom/full)

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
  String _status = "Initializing..."; // UI status message
  Timer? _timer; // Timer for polling API
  String? _predictionId; // ID returned by AI queue
  String? _sessionHash; // Unique session identifier

  static const String _hfSpaceUrl = 'https://yisol-idm-vton.hf.space'; // HuggingFace API URL
  int _pollCount = 0; // Number of polling attempts
  static const int _maxPolls = 60; // Max attempts before timeout

  @override
  void initState() {
    super.initState();
    _startTryOn();  // Start AR processing immediately
  }

  Future<void> _startTryOn() async {
    try {
      setState(() => _status = "Uploading to free AI model...");  // Update UI

      // Download images via HTTP
      final humanRes = await http.get(Uri.parse(widget.userImageUrl));
      final garmentRes = await http.get(Uri.parse(widget.productImageUrl));

      // Upload to HF
      final humanPath = await _uploadToGradio(humanRes.bodyBytes, 'human.jpg');  // Get user image
      final garmentPath = await _uploadToGradio(garmentRes.bodyBytes, 'garment.jpg');  // Upload product image
      
      setState(() => _status = "Submitting to AI queue...");  // Update UI

      // Decide clothing type description
      final garmentDesc = widget.category == 'bottoms'
          ? 'lower body clothing'
          : widget.category == 'one-pieces'
              ? 'full body clothing'
              : 'upper body clothing';

      final sessionHash = _generateSessionHash();  // Generate unique session

      // Send request to AI queue
      final joinRes = await http.post(
        Uri.parse('$_hfSpaceUrl/queue/join'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': [
            {
              'background': _makeFileData(humanPath, 'human.jpg'),  // user image
              'layers': [],
              'composite': null,
            },
            _makeFileData(garmentPath, 'garment.jpg'),  // product image
            garmentDesc,  // clothing type
            true,
            false,
            30,
            42,
          ],
          'event_data': null,
          'fn_index': 2,  // model function index
          'trigger_id': 6,
          'session_hash': sessionHash,
        }),
      );

      if (joinRes.statusCode != 200) {
        throw Exception('Failed to join AI queue');  // Error if request fails
      }

      final joinData = jsonDecode(joinRes.body);  // Parse response
      _predictionId = joinData['event_id'] as String?;  // Get prediction ID
      _sessionHash = sessionHash;

      // Start polling if everything is valid
      if (_predictionId != null && _sessionHash != null) {
        _startPolling();
      } else {
        _handleError("No prediction ID returned from server.");
      }
    } catch (e) {
      _handleError("Failed to start processing: $e");  // Handle error
    }
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {  // Poll every 3 seconds
      _pollCount++;

      // Stop if too many attempts
      if (_pollCount > _maxPolls) {
        timer.cancel();
        _handleError("Try-On took too long. Please try again.");
        return;
      }

      try {
        setState(() => _status = "Waiting in AI queue...");  // Update UI

        final client = http.Client();  // HTTP client
        if (_sessionHash == null) return;
        
        final uri = Uri.parse('$_hfSpaceUrl/queue/data?session_hash=$_sessionHash');  // Poll URL
        final request = http.Request('GET', uri)..headers['Accept'] = 'text/event-stream';

        String status = 'processing';   // Default state
        String? outputUrl;  // Final result image
        String? errorMsg;

        try {
          final response = await client.send(request).timeout(const Duration(seconds: 10)); // Send request
          final stream = response.stream.transform(utf8.decoder); // Decode stream

          await for (final chunk in stream) { // Listen to streaming response
            final blocks = chunk.split('\n\n'); // Split events

            for (final block in blocks) {
              final dataLine = block.split('\n').cast<String?>().firstWhere(
                    (l) => l != null && l.startsWith('data:'), // Find data line
                    orElse: () => null,
                  );
              if (dataLine == null) continue;
              
              try {
                final event = jsonDecode(dataLine.substring(5).trim());  // Parse JSON
                final msg = event['msg'];
                
                if (msg == 'process_completed') {  // Success case
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
          client.close();  // Close client
        }

        if (status == 'completed') {
          timer.cancel();  // Stop polling
          
          if (outputUrl != null && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ARResultScreen(imageUrl: outputUrl!)),  // Go to result screen
            );
          } else {
            _handleError("AI returned no image.");
          }
        } else if (status == 'failed') {
          timer.cancel();
          _handleError("Generation failed: ${errorMsg ?? 'Unknown error'}");
        }
      } catch (e) {
        debugPrint("Polling error: $e");  // Debug log
      }
    });
  }

  void _handleError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red));  // Show error
      Navigator.pop(context);  // Go back
    }
  }

  // ── HF API Helpers ───────────────────────────────────────────────────────
  // Upload image to HuggingFace (Gradio)
  Future<String> _uploadToGradio(List<int> bytes, String filename) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_hfSpaceUrl/upload'));
    request.files.add(http.MultipartFile.fromBytes('files', bytes, filename: filename));
    final response = await request.send();
    
    if (response.statusCode != 200) throw Exception('Upload failed');
    
    final respStr = await response.stream.bytesToString();
    final paths = jsonDecode(respStr) as List;
    return paths[0] as String;   // Return uploaded file path
  }

  // Create file metadata for API
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

  // Generate random session hash
  String _generateSessionHash() {
    final chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = dart_math.Random();
    return List.generate(11, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  void dispose() {
    _timer?.cancel();  // Stop polling when screen is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,  // Dark UI
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome,
                size: 80, color: AppColors.primaryRed),   // Icon
            
            const SizedBox(height: 30),
            
            Text(
              _status,  // Show current status
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            
            const SizedBox(height: 40),
            
            const CircularProgressIndicator(color: AppColors.primaryRed),  // Loader
          ],
        ),
      ),
    );
  }
}
