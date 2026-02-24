import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import '../../core/constants/app_colors.dart';

class ARTryOnScreen extends StatefulWidget {
  final String modelUrl;
  final String videoPath;

  const ARTryOnScreen({super.key, required this.modelUrl, required this.videoPath});

  @override
  State<ARTryOnScreen> createState() => _ARTryOnScreenState();
}

class _ARTryOnScreenState extends State<ARTryOnScreen> {
  UnityWidgetController? _unityController;
  bool _isReady = false;

  void onUnityCreated(controller) {
    _unityController = controller;

    // SAFETY DELAY: Wait for Unity to fully boot before sending the video
    Future.delayed(const Duration(seconds: 2), () {
      if (_unityController != null) {
        _unityController!.postMessage('Main Camera', 'SetVideoBackground', widget.videoPath);
        _unityController!.postMessage('Main Camera', 'GenerateAndLoadModel', widget.modelUrl);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          UnityWidget(
            onUnityCreated: onUnityCreated,
            onUnityMessage: (m) { if (m == "LOADED") setState(() => _isReady = true); },
            useAndroidViewSurface: true, // Set to false if it still crashes
          ),
          if (!_isReady)
            Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator(color: AppColors.primaryRed)),
            ),
          Positioned(
            top: 50, left: 20,
            child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _unityController?.dispose();
    super.dispose();
  }
}
