using UnityEngine;
using UnityEditor;
using UnityEngine.XR.ARFoundation;
using Unity.XR.CoreUtils;
using UnityEngine.SpatialTracking;

/// <summary>
/// One-click AR scene builder.
/// Menu: AngaFit → Build Full AR Scene
///
/// Builds the complete minimal AR scene hierarchy:
///   AR Session (ARSession + ARInputManager + ARSessionController)
///   XR Origin  (XROrigin + Camera Offset + Main Camera + ARCameraManager + ARCameraBackground + TrackedPoseDriver)
///   FlutterComm (FlutterCommunication + ARCoordinator)
///   [MainThreadDispatcher] (UnityMainThreadDispatcher)
/// </summary>
public class ARSceneSetup : EditorWindow
{
    [MenuItem("AngaFit/Build Full AR Scene")]
    public static void BuildFullScene()
    {
        if (EditorApplication.isPlaying)
        {
            EditorUtility.DisplayDialog("Stop Play Mode First",
                "Please stop Play mode before running scene setup.", "OK");
            return;
        }

        // ── 1. Clean stale objects ────────────────────────────────────────────
        DestroyIfExists("AR Session");
        DestroyIfExists("XR Origin");
        DestroyIfExists("FlutterComm");
        DestroyIfExists("[MainThreadDispatcher]");

        // ── 2. AR SESSION ─────────────────────────────────────────────────────
        var arSessionGO = new GameObject("AR Session");
        arSessionGO.AddComponent<ARSession>();
        arSessionGO.AddComponent<ARInputManager>();
        arSessionGO.AddComponent<ARSessionController>();

        // ── 3. XR ORIGIN ──────────────────────────────────────────────────────
        var xrOriginGO = new GameObject("XR Origin");
        var xrOrigin   = xrOriginGO.AddComponent<XROrigin>();

        var cameraOffset = new GameObject("Camera Offset");
        cameraOffset.transform.SetParent(xrOriginGO.transform, false);

        var arCameraGO = new GameObject("Main Camera");
        arCameraGO.transform.SetParent(cameraOffset.transform, false);
        arCameraGO.tag = "MainCamera";

        var cam             = arCameraGO.AddComponent<Camera>();
        cam.clearFlags      = CameraClearFlags.Depth;
        cam.nearClipPlane   = 0.1f;
        cam.farClipPlane    = 100f;
        cam.fieldOfView     = 60f;

        var arCameraManager = arCameraGO.AddComponent<ARCameraManager>();
        arCameraManager.requestedFacingDirection = CameraFacingDirection.World;
        arCameraManager.autoFocusRequested       = true;
        arCameraGO.AddComponent<ARCameraBackground>();

        // Use Legacy TrackedPoseDriver — the Input System version doesn't fire without
        // explicit Input Action bindings, which are not set up in this project.
        var tpd = arCameraGO.AddComponent<TrackedPoseDriver>();
        tpd.SetPoseSource(TrackedPoseDriver.DeviceType.GenericXRDevice,
                          TrackedPoseDriver.TrackedPose.ColorCamera);
        tpd.trackingType = TrackedPoseDriver.TrackingType.RotationAndPosition;
        tpd.updateType   = TrackedPoseDriver.UpdateType.UpdateAndBeforeRender;

        xrOrigin.Camera                 = cam;
        xrOrigin.CameraFloorOffsetObject = cameraOffset;

        // ── 4. FLUTTER COMM (this GameObject must be named "FlutterComm") ────
        var flutterCommGO    = new GameObject("FlutterComm");
        var coordinator      = flutterCommGO.AddComponent<ARCoordinator>();
        var flutterCommComp  = flutterCommGO.AddComponent<FlutterCommunication>();

        // Wire ARCoordinator reference
        var fcSO = new SerializedObject(flutterCommComp);
        fcSO.FindProperty("coordinator").objectReferenceValue = coordinator;
        fcSO.ApplyModifiedProperties();

        // ── 5. MAIN THREAD DISPATCHER ─────────────────────────────────────────
        var dispatcherGO = new GameObject("[MainThreadDispatcher]");
        dispatcherGO.AddComponent<UnityMainThreadDispatcher>();

        // ── 6. MARK DIRTY & REPORT ────────────────────────────────────────────
        UnityEditor.SceneManagement.EditorSceneManager.MarkSceneDirty(
            UnityEngine.SceneManagement.SceneManager.GetActiveScene());

        Selection.activeGameObject = xrOriginGO;

        Debug.Log("[AngaFit] AR scene built successfully.");
        EditorUtility.DisplayDialog(
            "✅ AR Scene Ready!",
            "Scene created:\n\n" +
            "• AR Session\n" +
            "• XR Origin + AR Camera (Legacy TrackedPoseDriver)\n" +
            "• FlutterComm (FlutterCommunication + ARCoordinator)\n" +
            "• [MainThreadDispatcher]\n\n" +
            "Press Ctrl+S to save the scene, then Export to Android.",
            "Got it!"
        );
    }

    private static void DestroyIfExists(string name)
    {
        var go = GameObject.Find(name);
        if (go != null) Object.DestroyImmediate(go);
    }
}