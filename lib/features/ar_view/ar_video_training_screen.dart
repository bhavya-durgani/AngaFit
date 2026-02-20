import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_colors.dart';
import 'ar_try_on_screen.dart';

class ARVideoTrainingScreen extends StatefulWidget {
  final String modelName;
  const ARVideoTrainingScreen({super.key, required this.modelName});

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
    "Processing your fit..."
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _startRecordingSequence() async {
    setState(() => _isRecording = true);
    await _controller!.startVideoRecording();

    // Sequence logic
    for (int i = 0; i < 4; i++) {
      setState(() => _currentStep = i);
      await Future.delayed(const Duration(seconds: 4));
    }

    XFile videoFile = await _controller!.stopVideoRecording();
    setState(() => _currentStep = 4);

    // Redirect to Unity View with the recorded video
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ARTryOnScreen(
            modelName: widget.modelName,
            videoPath: videoFile.path,
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
          // UI OVERLAY
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    _prompts[_currentStep],
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                if (!_isRecording)
                  ElevatedButton(
                    onPressed: _startRecordingSequence,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                    child: const Text("START 360° CAPTURE"),
                  ),
                if (_isRecording && _currentStep < 4)
                  const CircularProgressIndicator(color: AppColors.primaryRed),
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
