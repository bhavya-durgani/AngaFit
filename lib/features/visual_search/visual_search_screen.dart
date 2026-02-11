import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'processing_fit_screen.dart';

class VisualSearchScreen extends StatelessWidget {
  const VisualSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Placeholder
          Container(color: Colors.grey.shade900),
          Positioned(
            top: 50, left: 20,
            child: IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white, size: 35), onPressed: () => Navigator.pop(context)),
          ),
          const Positioned(
            top: 60, left: 0, right: 0,
            child: Center(child: Text("Search by photo", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          ),
          Positioned(
            bottom: 50, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.flash_off, color: Colors.white),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProcessingFitScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.primaryRed, width: 3), shape: BoxShape.circle),
                    child: const CircleAvatar(radius: 30, backgroundColor: AppColors.primaryRed, child: Icon(Icons.camera_alt, color: Colors.white)),
                  ),
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
