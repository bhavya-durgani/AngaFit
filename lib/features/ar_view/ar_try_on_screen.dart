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
    // Tell Unity to play the video and load the cloth
    _unityController!.postMessage('ModelLoader', 'SetVideoBackground', widget.videoPath);
    _unityController!.postMessage('ModelLoader', 'ChangeOutfit', widget.modelName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          UnityWidget(
            onUnityCreated: onUnityCreated,
            useAndroidViewSurface: true,
          ),
          Positioned(
            top: 50, left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ),
          ),
          Positioned(
            bottom: 30, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(15)),
              child: const Text(
                "360° View: Watch how the outfit moves with you",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          )
        ],
      ),
    );
  }
}
