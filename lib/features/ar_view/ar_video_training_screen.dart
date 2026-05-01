import 'dart:async'; 
// Used for Timer (step delays during capture flow)

import 'package:camera/camera.dart'; 
// Used to access device camera

import 'package:flutter/material.dart';
// Flutter UI framework

import 'package:image_picker/image_picker.dart';
// Used to pick image from gallery

import 'package:firebase_auth/firebase_auth.dart';
// Used to get current logged-in user UID

import '../../core/constants/app_colors.dart';
// App color constants

import '../../data/services/storage_service.dart';
// Service for uploading images to Firebase Storage

import '../../data/dummy_data.dart';
// Contains Product model (used for ARTryOnScreen)

import 'ar_try_on_screen.dart';
// Navigates to AR try-on (AI + Unity flow)

import 'ar_processing_screen.dart';
// Navigates to AI processing pipeline (2D flow)

class ARVideoTrainingScreen extends StatefulWidget {
  // Screen where 360° capture or photo try-on starts

  final String modelName;
  // Name of product/model

  final String modelUrl;
  // Unity/3D model URL

  final String productImageUrl;
  // Product image used for AI try-on

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
  // State class controlling camera + capture flow

  CameraController? _controller;
  // Controls camera preview and recording

  int _currentStep = 0;
  // Tracks instruction step during 360° capture

  bool _isRecording = false;
  // Tracks if video recording is active

  bool _isUploading = false;
  // Tracks if image upload is in progress

  final List<String> _prompts = [
    // Instructions shown during 360° capture

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
    // Initialize camera when screen opens
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      // Get all available cameras

      if (cameras.isEmpty) return;
      // If no camera found, stop

      final cam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      // Select back camera for AR capture

      _controller = CameraController(
        cam,
        ResolutionPreset.high,
        enableAudio: false,
      );
      // Create camera controller (high quality video)

      await _controller!.initialize();
      // Initialize camera

      if (mounted) setState(() {});
      // Refresh UI after initialization

    } catch (e) {
      debugPrint('Camera init error: $e');
      // Print error if camera fails
    }
  }

  Future<void> _pickAndProcessPhoto() async {
    // Handles 2D image-based try-on

    final picker = ImagePicker();
    // Image picker instance

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80
    );
    // Pick image from gallery

    if (image != null) {
      setState(() => _isUploading = true);
      // Show uploading state

      final uid = FirebaseAuth.instance.currentUser?.uid;
      // Get logged-in user ID

      if (uid == null) {
        // If user not logged in
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login first"))
        );
        setState(() => _isUploading = false);
        return;
      }

      final imageUrl = await StorageService().uploadUserImage(
        image.path,
        uid
      );
      // Upload image to Firebase Storage

      if (imageUrl != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ARProcessingScreen(
              userImageUrl: imageUrl,
              productImageUrl: widget.productImageUrl,
              category: "tops", // Default category
            ),
          ),
        );
        // Navigate to AI processing screen

      } else if (mounted) {
        _showError("Failed to upload image.");
        setState(() => _isUploading = false);
      }
    }
  }

  void _showError(String msg) {
    // Show error snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red)
    );
  }

  Future<void> _startCapture() async {
    // Starts 360° video recording flow

    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isRecording = true);
    // Start recording state

    await _controller!.startVideoRecording();
    // Begin video recording

    for (int i = 0; i < 4; i++) {
      // Loop through capture steps

      if (!mounted) return;

      setState(() => _currentStep = i);
      // Update instruction step

      await Future.delayed(const Duration(seconds: 4));
      // Wait for user to rotate body
    }

    await _controller?.dispose();
    // Stop camera after recording

    _controller = null;

    await Future.delayed(const Duration(seconds: 1));
    // Small delay for cleanup

    if (mounted) {
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
      // Navigate to AR try-on system (AI / Unity pipeline)
    }
  }

  @override
  Widget build(BuildContext context) {
    // Builds UI

    if (_isUploading) {
      // Show upload loader screen
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
      // Show loading until camera is ready
      return const Scaffold(
        body: Center(child: CircularProgressIndicator())
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [

          CameraPreview(_controller!),
          // Live camera preview

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60),

            child: Column(
              children: [

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20)
                  ),

                  child: Text(
                    _prompts[_currentStep],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  // Show current instruction
                ),

                const Spacer(),

                if (!_isRecording) ...[
                  // Buttons before recording

                  ElevatedButton(
                    onPressed: _startCapture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed
                    ),
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

                if (_isRecording)
                  const CircularProgressIndicator(
                    color: AppColors.primaryRed
                  ),
                // Show loader during recording
              ],
            ),
          ),

          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              // Back button
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    // Free camera resources
    super.dispose();
  }
}
