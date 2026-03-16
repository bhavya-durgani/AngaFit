import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'dart:convert';

/// Thin helper around [UnityWidgetController] so AR screens don't
/// need to know exact GameObject names or method strings.
class UnityService {
  final UnityWidgetController controller;

  const UnityService(this.controller);

  /// Tell Unity to download and display a clothing product.
  void loadProduct(String id, String glbUrl) {
    final payload = jsonEncode({'id': id, 'url': glbUrl});
    controller.postMessage('FlutterComm', 'LoadProduct', payload);
  }

  /// Change the size displayed on the ar outfit (S/M/L/XL).
  void setSize(String sizeLabel) {
    controller.postMessage('FlutterComm', 'SetSize', sizeLabel);
  }

  /// Toggle between front and back view ('front' or 'back').
  void setView(String view) {
    controller.postMessage('FlutterComm', 'SetView', view);
  }

  /// Request a screenshot — Unity will reply with SCREENSHOT:/path message.
  void takeScreenshot() {
    controller.postMessage('FlutterComm', 'TakeScreenshot', '');
  }

  /// Clear cached .glb files in Unity's persistent storage.
  void clearCache() {
    controller.postMessage('FlutterComm', 'ClearCache', '');
  }
}
