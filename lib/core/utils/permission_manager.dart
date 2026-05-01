import 'package:permission_handler/permission_handler.dart';  
// Imports permission_handler package (used to request device permissions)

class PermissionManager {  
  // Class to handle permission requests (camera, storage, etc.)

  static Future<bool> requestCameraPermission() async {  
    // Function to request camera permission (returns true/false)

    var status = await Permission.camera.status;  
    // Check current camera permission status

    if (status.isDenied) {  
      // If permission is denied

      status = await Permission.camera.request();  
      // Ask user to allow camera permission
    }

    return status.isGranted;  
    // Return true if permission is granted, otherwise false
  }

  static Future<bool> requestStoragePermission() async {  
    // Function to request storage permission

    var status = await Permission.storage.status;  
    // Check current storage permission status

    if (status.isDenied) {  
      // If permission is denied

      status = await Permission.storage.request();  
      // Ask user to allow storage permission
    }

    return status.isGranted;  
    // Return true if permission is granted
  }
}
