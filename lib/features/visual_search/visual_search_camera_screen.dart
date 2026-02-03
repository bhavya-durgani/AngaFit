import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class VisualSearchCameraScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview Placeholder
          Container(color: Colors.grey[300], width: double.infinity, height: double.infinity),

          Positioned(
            top: 50, left: 20,
            child: IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32), onPressed: () => Navigator.pop(context)),
          ),

          const Positioned(
            top: 55, left: 0, right: 0,
            child: Center(child: Text("Start the video", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          ),

          // Camera Controls
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.flash_on, color: Colors.white),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.primaryRed, width: 2), shape: BoxShape.circle),
                  child: const CircleAvatar(radius: 28, backgroundColor: AppColors.primaryRed, child: Icon(Icons.camera_alt, color: Colors.white)),
                ),
                const Icon(Icons.sync, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
