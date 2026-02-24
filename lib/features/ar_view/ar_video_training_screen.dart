import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'ar_try_on_screen.dart';

class ARVideoTrainingScreen extends StatefulWidget {
  final String modelName;
  final String modelUrl;

  const ARVideoTrainingScreen({super.key, required this.modelName, required this.modelUrl});

  @override
  State<ARVideoTrainingScreen> createState() => _ARVideoTrainingScreenState();
}

class _ARVideoTrainingScreenState extends State<ARVideoTrainingScreen> {
  CameraController? _controller;
  int _currentStep = 0;
  bool _isRecording = false;
  final List<String> _prompts = [
    "Look straight at the camera",
    "Slowly turn to your LEFT",
    "Slowly turn to your RIGHT",
    "Turn around COMPLETELY (360°)",
    "Finalizing video..."
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _startCapture() async {
    setState(() => _isRecording = true);
    await _controller!.startVideoRecording();

    for (int i = 0; i < 4; i++) {
      setState(() => _currentStep = i);
      await Future.delayed(const Duration(seconds: 4));
    }

    XFile video = await _controller!.stopVideoRecording();
    setState(() => _currentStep = 4);

    // CRITICAL FIX: Dispose and wait for 1 second
    await _controller?.dispose();
    _controller = null;
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      // Navigate to Unity
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ARTryOnScreen(
            modelUrl: widget.modelUrl,
            videoPath: video.path,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Text(_prompts[_currentStep], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                if (!_isRecording)
                  ElevatedButton(onPressed: _startCapture, child: const Text("START CAPTURE")),
                if (_isRecording) const CircularProgressIndicator(color: AppColors.primaryRed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
