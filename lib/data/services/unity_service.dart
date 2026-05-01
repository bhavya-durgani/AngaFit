import 'package:flutter_unity_widget/flutter_unity_widget.dart';  
// Imports Flutter-Unity bridge (used to communicate with Unity)

import 'dart:convert';  
// Imports JSON encoder (used to send structured data to Unity)

/// Thin helper around [UnityWidgetController] so AR screens don't
/// need to know exact GameObject names or method strings.
class UnityService {  
  // Service class to simplify communication between Flutter and Unity

  final UnityWidgetController controller;  
  // Controller used to send messages to Unity

  const UnityService(this.controller);  
  // Constructor to initialize controller

  /// Tell Unity to download and display a clothing product.
  void loadProduct(String id, String glbUrl) {  
    // Function to load a 3D product model in Unity

    final payload = jsonEncode({'id': id, 'url': glbUrl});  
    // Convert product ID and model URL into JSON format

    controller.postMessage('FlutterComm', 'LoadProduct', payload);  
    // Send message to Unity:
    // GameObject: FlutterComm
    // Method: LoadProduct
    // Data: JSON payload
  }

  /// Change the size displayed on the AR outfit (S/M/L/XL).
  void setSize(String sizeLabel) {  
    // Function to change size of clothing model

    controller.postMessage('FlutterComm', 'SetSize', sizeLabel);  
    // Send size value to Unity
  }

  /// Toggle between front and back view ('front' or 'back').
  void setView(String view) {  
    // Function to change view (front/back)

    controller.postMessage('FlutterComm', 'SetView', view);  
    // Send view type to Unity
  }

  /// Request a screenshot — Unity will reply with SCREENSHOT:/path message.
  void takeScreenshot() {  
    // Function to capture screenshot from Unity scene

    controller.postMessage('FlutterComm', 'TakeScreenshot', '');  
    // Send request to Unity (no extra data needed)
  }

  /// Clear cached .glb files in Unity's persistent storage.
  void clearCache() {  
    // Function to clear stored 3D models in Unity

    controller.postMessage('FlutterComm', 'ClearCache', '');  
    // Send clear cache command to Unity
  }
}
