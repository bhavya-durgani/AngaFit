import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class ARTryOnScreen extends StatefulWidget {
  const ARTryOnScreen({super.key});
  @override State<ARTryOnScreen> createState() => _ARTryOnScreenState();
}

class _ARTryOnScreenState extends State<ARTryOnScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          UnityWidget(
            onUnityCreated: (controller) {},
            useAndroidViewSurface: true,
          ),
          Positioned(
            top: 50, left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ),
          ),
        ],
      ),
    );
  }
}
