import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fetches the download URL for a 3D model stored in Firebase Storage
  Future<String?> getUnityModelUrl(String modelName) async {
    try {
      // Assumes models are stored in a 'models' folder in Firebase Storage
      return await _storage.ref('models/$modelName.unity3d').getDownloadURL();
    } catch (e) {
      print("Error fetching 3D model: $e");
      return null;
    }
  }
}
