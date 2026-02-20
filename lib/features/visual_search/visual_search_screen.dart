import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import 'processing_fit_screen.dart';

class VisualSearchScreen extends StatelessWidget {
  const VisualSearchScreen({super.key});

  Future<void> _handleImageAction(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source);

    if (photo != null && context.mounted) {
      // Redirect to the "Processing your fit" animation
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProcessingFitScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background UI
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Search by photo",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              _buildLargeBtn(context, "TAKE A PHOTO", Icons.camera_alt, ImageSource.camera),
              const SizedBox(height: 16),
              _buildLargeBtn(context, "UPLOAD FROM GALLERY", Icons.image, ImageSource.gallery),
            ],
          ),
          // Close Button
          Positioned(
            top: 50, left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeBtn(BuildContext context, String label, IconData icon, ImageSource source) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, foregroundColor: Colors.white),
          onPressed: () => _handleImageAction(context, source),
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }
}
