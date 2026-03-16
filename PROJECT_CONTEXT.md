# AngaFit Project Context

## Project Overview
AngaFit is an AR-based shopping app built primarily with Flutter for the mobile frontend and Unity (AR Foundation) for the Augmented Reality / Virtual Try-On experiences. The app allows users to browse a clothing catalog, view details, manage a cart, process payments via Stripe, and interact with an "AR Try-On" feature that leverages a 2D Virtual Try-On (VTON) AI model.

## Technology Stack
- **Frontend / Mobile App**: Flutter (Dart). Uses `provider` for state management and `flutter_unity_widget` to bridge Unity into Flutter.
- **Backend (BaaS)**: Firebase (Firebase Authentication, Cloud Firestore, Firebase Storage) and Firebase Cloud Functions (used for processing VTON AI endpoints).
- **Augmented Reality**: Unity (`2022.2.X` via `flutter_unity_widget`) + AR Foundation. Located in the `unity/ar_cart` sub-project and exported as an Android Library (`android/unityLibrary`).
- **Payments Integration**: Stripe (`flutter_stripe` package).

## Core Flutter Dependencies (`pubspec.yaml`)
- **Backend**: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `cloud_functions`, `google_sign_in`
- **Native Bridges & UI**: `flutter_unity_widget`, `flutter_stripe`, `camera`, `video_player`, `image_picker`, `permission_handler`, `path_provider`
- **State & Utils**: `provider`, `cached_network_image`, `google_fonts`, `http`

## Directory Structure & Architecture

### Flutter App (`lib/`)
The app utilizes a feature-first component folder structure:
- `core/`: Contains app constants, global providers, UI themes, and utility functions.
- `data/`: Data models and backend interaction code. Key services include:
  - `auth_service.dart`, `database_service.dart`, `storage_service.dart` (Firebase operations)
  - `stripe_service.dart` (Payments/Checkout API integration)
  - `unity_service.dart` (Logic handling Unity messages/state)
- `features/`: Houses the modular UI and logic for different screens:
  - `ar_view`: The core AR Try-On screen integrating `flutter_unity_widget`, managing camera captures, and VTON interactions.
  - `auth`, `home`, `splash`, `navigation`: App lifecycle, authentication, and layout scaffolding.
  - `catalog`, `product_details`, `search`, `visual_search`: Product browsing, AI-driven visual search, and catalog details.
  - `cart`, `checkout`: E-commerce transaction logic connected to Stripe.
  - `favorites`, `profile`, `reviews`, `admin`: User/admin profile, saved items, and reviews. 

### Unity AR Scene (`unity/ar_cart/`)
- Contains the `ARSceneSetup.cs` and other scripts that manage the Unity camera feed and the AR foundation framework. 
- Integrated into the Android build pipeline via `android/unityLibrary`. It acts strictly as an AR view bridging the device camera stream and pose tracking over to the Flutter UI hierarchy with customized transparency configurations.

## Current System State & Key Integrations
1. **AR Try-On Bridging & VTON**: The Flutter app communicates heavily with the Unity context via platform channels. Unity manages the AR camera tracking overlay, while Firebase Cloud Functions accept captured user photos + garment images to return synthesized (VTON) try-on output.
2. **Authentication Flow**: Firebase Authentication handles sign-in with email & Google.
3. **Checkout flow**: fully powered by the `flutter_stripe` SDK initializing Payment Sheets when transitioning out of the `checkout` feature directory.

## Flutter & Unity Integration Points
The core bridge between the Flutter app and the Unity AR view is established through the following key files. If the AR Try-On feature is failing or not communicating properly, these are the primary files to check:

### Flutter Files Triggering Unity
- **`lib/features/ar_view/ar_try_on_screen.dart`**: This is the main screen containing the `UnityWidget`.
  - Listens to Unity via `_onUnityMessage` (e.g., waiting for `"READY"`, `"BODY_DETECTED"`, `"OUTFIT_APPLIED"`, `"DOWNLOAD_PROGRESS:"`, `"SCREENSHOT:"`).
  - Sends commands to Unity via `_unityController?.postMessage('FlutterComm', 'CommandName', 'payload')` (e.g., `LoadProduct`, `SetSize`, `SetView`, `TakeScreenshot`).

### Unity Scripts Handling Flutter Communication
- **`unity/ar_cart/Assets/Scripts/FlutterCommunication.cs`**: The central switchboard on the Unity side.
  - Attached to a GameObject named **exactly** `FlutterComm`.
  - Provides methods like `LoadProduct(string json)`, `SetSize(string)`, `SetView(string)`, and `TakeScreenshot(string)` which are invoked directly by Flutter.
  - Uses `UnityMessageManager.Instance.SendMessageToFlutter(message)` to send string payloads back to Dart.
- **`unity/ar_cart/Assets/Scripts/ARSessionController.cs`**: Manages the AR session lifecycle.
  - Responsible for firing the initial `"READY"` message back to Flutter once the AR tracking is initialized, which unlocks the Flutter UI to start sending product load commands.

### Other Important Unity Files to Check
If the AR Try-On feature is not working despite communication being successful, check these related systems inside `unity/ar_cart/Assets/Scripts/`:
- **`AROutfitController.cs`** (or `ClothingManager`): Handles the actual spawning and aligning of the 3D garment.
- **`ModelDownloader.cs`**: Handles fetching `.glb` model files from URLs provided by Flutter and reports `DOWNLOAD_PROGRESS:`.
- **`BodyTrackingManager.cs`**: Deals with the device-specific body tracking (ARKit for iOS / ML Kit for Android).
- **`CameraCapture.cs`**: Handles capturing the AR scene for screenshots.
