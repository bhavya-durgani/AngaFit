import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get the 3D model URL based on the product name
  Future<String> getModelUrl(String modelName) async {
    try {
      // Looks for a file like 'models/evening_dress.unity3d'
      String url = await _storage
          .ref('models/$modelName.unity3d')
          .getDownloadURL();
      return url;
    } catch (e) {
      print("Error fetching model: $e");
      return "";
    }
  }
}
