import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import '../../core/constants/app_colors.dart';

class ARTryOnScreen extends StatefulWidget {
  final String modelName; // Passed from the Product Details screen

  const ARTryOnScreen({
    super.key,
    this.modelName = "default_shirt" // Fallback if no name is provided
  });

  @override
  State<ARTryOnScreen> createState() => _ARTryOnScreenState();
}

class _ARTryOnScreenState extends State<ARTryOnScreen> {
  UnityWidgetController? _unityWidgetController;
  bool _isUnityReady = false;
  bool _isModelLoaded = false;

  @override
  void dispose() {
    _unityWidgetController?.dispose();
    super.dispose();
  }

  // Called when the Unity view is rendered and ready
  void onUnityCreated(controller) {
    _unityWidgetController = controller;
    setState(() {
      _isUnityReady = true;
    });

    // Tell Unity to load the specific clothing model
    _loadModelInUnity();
  }

  // Communicates with the C# script in Unity
  void _loadModelInUnity() {
    if (_unityWidgetController != null) {
      // 'ModelLoader' is the name of the GameObject in your Unity scene
      // 'ChangeOutfit' is the function name in your AROutfitController.cs
      _unityWidgetController!.postMessage(
          'ModelLoader',
          'ChangeOutfit',
          widget.modelName
      );
    }
  }

  // Handles messages sent FROM Unity to Flutter
  void onUnityMessage(message) {
    print('Message from Unity: ${message.toString()}');

    if (message == "LOADED") {
      setState(() {
        _isModelLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. THE AR VIEW (UNITY WIDGET)
          UnityWidget(
            onUnityCreated: onUnityCreated,
            onUnityMessage: onUnityMessage,
            useAndroidViewSurface: true, // Crucial for AR performance on Android
            fullscreen: true,
          ),

          // 2. BACK BUTTON OVERLAY
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 3. LOADING INDICATOR
          if (!_isModelLoaded)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primaryRed),
                    const SizedBox(height: 20),
                    Text(
                      "Initializing AR Engine...",
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ),

          // 4. INSTRUCTION OVERLAY
          if (_isModelLoaded)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.accessibility_new, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        "Align your body within the frame",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 5. CAPTURE BUTTON (Optional)
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                // Logic to take a screenshot of the AR view
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Snapshot saved to gallery!")),
                );
              },
              child: const Icon(Icons.camera_alt, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
