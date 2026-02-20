import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import '../../core/constants/app_colors.dart';

class ARTryOnScreen extends StatefulWidget {
  final String modelName;
  final String videoPath;

  const ARTryOnScreen({super.key, required this.modelName, required this.videoPath});

  @override
  State<ARTryOnScreen> createState() => _ARTryOnScreenState();
}

class _ARTryOnScreenState extends State<ARTryOnScreen> {
  UnityWidgetController? _unityController;

  void onUnityCreated(controller) {
    _unityController = controller;

    // 1. Send the recorded video path to Unity
    _unityController!.postMessage(
        'ModelLoader',
        'SetVideoBackground',
        widget.videoPath
    );

    // 2. Tell Unity which dress to show
    _unityController!.postMessage(
        'ModelLoader',
        'ChangeOutfit',
        widget.modelName
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The Unity Engine
          UnityWidget(
            onUnityCreated: onUnityCreated,
            useAndroidViewSurface: true,
          ),

          // UI Overlays
          Positioned(
            top: 50, left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: const Text(
                  "Virtual Fitting: See how the dress looks as you move",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
