import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/storage_service.dart';
import '../../data/dummy_data.dart';
import 'ar_try_on_screen.dart';
import 'ar_processing_screen.dart';

class ARVideoTrainingScreen extends StatefulWidget {
  final String modelName;
  final String modelUrl;
  final String productImageUrl; // Added product image URL

  const ARVideoTrainingScreen({
    super.key, 
    required this.modelName, 
    required this.modelUrl,
    required this.productImageUrl,
  });

  @override
  State<ARVideoTrainingScreen> createState() => _ARVideoTrainingScreenState();
}

class _ARVideoTrainingScreenState extends State<ARVideoTrainingScreen> {
  CameraController? _controller;
  int _currentStep = 0;
  bool _isRecording = false;
  bool _isUploading = false;

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
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      // Use back camera as requested
      final cam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _controller = CameraController(cam, ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _pickAndProcessPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (image != null) {
      setState(() => _isUploading = true);
      
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login first")));
        setState(() => _isUploading = false);
        return;
      }

      final imageUrl = await StorageService().uploadUserImage(image.path, uid);
      
      if (imageUrl != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ARProcessingScreen(
              userImageUrl: imageUrl,
              productImageUrl: widget.productImageUrl,
              category: "tops", // Default to tops, could be dynamic
            ),
          ),
        );
      } else if (mounted) {
        _showError("Failed to upload image.");
        setState(() => _isUploading = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<void> _startCapture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    setState(() => _isRecording = true);
    await _controller!.startVideoRecording();

    for (int i = 0; i < 4; i++) {
      if (!mounted) return;
      setState(() => _currentStep = i);
      await Future.delayed(const Duration(seconds: 4));
    }

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
            product: Product(
              name: widget.modelName,
              brand: "AngaFit",
              price: 0.0,
              imageUrl: widget.productImageUrl,
              description: "",
              composition: "",
              care: "",
              unityModelUrl: widget.modelUrl,
              availableSizes: ["S", "M", "L", "XL"],
              availableColors: [],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUploading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryRed),
              SizedBox(height: 20),
              Text("Uploading photo...", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

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
                if (!_isRecording) ...[
                  ElevatedButton(
                    onPressed: _startCapture, 
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
                    child: const Text("START 3D CAPTURE"),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _pickAndProcessPhoto,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("USE PHOTO TRY-ON (2D)"),
                  ),
                ],
                if (_isRecording) const CircularProgressIndicator(color: AppColors.primaryRed),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
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
