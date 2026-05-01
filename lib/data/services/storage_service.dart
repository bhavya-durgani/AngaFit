import 'dart:io';  
// Imports File handling (used to read files from device)

import 'package:flutter/foundation.dart';  
// Imports debugPrint (used for logging errors)

import 'package:firebase_storage/firebase_storage.dart';  
// Imports Firebase Storage (used to upload/download files)

class StorageService {  
  // Service class to handle file uploads/downloads (models, images)

  final FirebaseStorage _storage = FirebaseStorage.instance;  
  // Get Firebase Storage instance

  /// Upload a .glb 3D clothing model to Firebase Storage.
  /// Returns the public download URL.
  Future<String?> uploadGlbModel(
    String filePath,  
    // Local file path of the .glb model

    String productName, {
    void Function(double)? onProgress,  
    // Optional callback to track upload progress
  }) async {
    try {
      final file = File(filePath);  
      // Convert file path into File object

      final fileName = '${productName.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.glb';  
      // Create unique file name (product name + timestamp)

      final ref = _storage.ref('models/glb/$fileName');  
      // Create reference path in Firebase Storage

      final task = ref.putFile(
        file, 
        SettableMetadata(contentType: 'model/gltf-binary')
      );  
      // Upload file with correct content type

      // Report progress
      task.snapshotEvents.listen((snapshot) {  
        // Listen to upload progress

        if (snapshot.totalBytes > 0 && onProgress != null) {
          onProgress(snapshot.bytesTransferred / snapshot.totalBytes);  
          // Send progress percentage to UI (0 to 1)
        }
      });

      await task;  
      // Wait until upload completes

      return await ref.getDownloadURL();  
      // Return public URL of uploaded model

    } catch (e) {  
      // Catch any error

      debugPrint('Error uploading GLB model: $e');  
      // Print error in debug console

      return null;  
      // Return null if failed
    }
  }

  /// Get download URL for a GLB model already in Firebase Storage.
  Future<String?> getGlbModelUrl(String fileName) async {  
    // Function to get URL of existing model

    try {
      return await _storage.ref('models/glb/$fileName').getDownloadURL();  
      // Fetch download URL from Firebase Storage
    } catch (e) {
      debugPrint('Error fetching GLB model URL: $e');  
      // Print error

      return null;  
      // Return null if failed
    }
  }

  /// Upload a user photo for Virtual Try-On.
  Future<String?> uploadUserImage(String filePath, String userId) async {  
    // Upload user image (used in AR try-on feature)

    try {
      final file = File(filePath);  
      // Convert file path to File object

      final ref = _storage.ref(
        'user_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg'
      );  
      // Create unique path using userId + timestamp

      await ref.putFile(file);  
      // Upload image file

      return await ref.getDownloadURL();  
      // Return image URL

    } catch (e) {
      debugPrint('Error uploading user image: $e');  
      // Print error

      return null;  
      // Return null if upload fails
    }
  }
}
