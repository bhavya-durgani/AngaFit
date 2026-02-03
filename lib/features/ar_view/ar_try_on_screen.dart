import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class ARTryOnScreen extends StatefulWidget {
  const ARTryOnScreen({super.key});

  @override
  State<ARTryOnScreen> createState() => _ARTryOnScreenState();
}

class _ARTryOnScreenState extends State<ARTryOnScreen> {
  UnityWidgetController? _unityWidgetController;

  // This is called when the Unity scene is ready
  void onUnityCreated(controller) {
    _unityWidgetController = controller;
    // You can send a message to Unity here to load a specific model
    // _unityWidgetController?.postMessage('ModelLoader', 'LoadModel', 'jacket_01');
  }

  // This handles messages sent FROM Unity to Flutter
  void onUnityMessage(message) {
    print('Received message from Unity: ${message.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The actual Unity AR View
          UnityWidget(
            onUnityCreated: onUnityCreated,
            onUnityMessage: onUnityMessage,
            useAndroidViewSurface: true, // Required for AR performance on Android
          ),

          // UI Overlays
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

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Scanning for body tracking...",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),

          // Optional: Shutter button to take AR photo
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                // Logic to capture AR screenshot
              },
              child: const Icon(Icons.camera_alt, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _unityWidgetController?.dispose();
    super.dispose();
  }
}
