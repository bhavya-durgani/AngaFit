import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a .glb 3D clothing model to Firebase Storage.
  /// Returns the public download URL.
  Future<String?> uploadGlbModel(
    String filePath,
    String productName, {
    void Function(double)? onProgress,
  }) async {
    try {
      final file = File(filePath);
      final fileName = '${productName.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.glb';
      final ref = _storage.ref('models/glb/$fileName');

      final task = ref.putFile(file, SettableMetadata(contentType: 'model/gltf-binary'));

      // Report progress
      task.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0 && onProgress != null) {
          onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
        }
      });

      await task;
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading GLB model: $e');
      return null;
    }
  }

  /// Get download URL for a GLB model already in Firebase Storage.
  Future<String?> getGlbModelUrl(String fileName) async {
    try {
      return await _storage.ref('models/glb/$fileName').getDownloadURL();
    } catch (e) {
      debugPrint('Error fetching GLB model URL: $e');
      return null;
    }
  }

  /// Upload a user photo for Virtual Try-On.
  Future<String?> uploadUserImage(String filePath, String userId) async {
    try {
      final file = File(filePath);
      final ref = _storage.ref('user_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading user image: $e');
      return null;
    }
  }
}
