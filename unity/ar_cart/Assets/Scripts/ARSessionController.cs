using System.Collections;                  // Allows use of IEnumerator (for coroutines)
using UnityEngine;                        // Core Unity engine library
using UnityEngine.XR.ARFoundation;        // AR Foundation package (for AR features)

/// <summary>
/// ARSessionController — Minimal entry point for the AR scene.
/// Waits briefly for UnityMessageManager to connect, then tells Flutter it's READY.
/// Also immediately sends BODY_DETECTED so the Flutter UI unlocks to send LoadProduct.
/// </summary>

[RequireComponent(typeof(ARSession))]     // Ensures this GameObject MUST have ARSession component
public class ARSessionController : MonoBehaviour
{
    private bool _initialized = false;    // Flag to prevent multiple initializations

    // Coroutine that runs when scene starts
    IEnumerator Start()
    {
        if (_initialized) yield break;    // If already initialized, stop execution
        _initialized = true;              // Mark as initialized

        // Small delay to allow Flutter-Unity connection setup
        yield return new WaitForSeconds(0.6f);

        Debug.Log("[ARSessionController] Sending READY to Flutter."); // Log message
        FlutterCommunication.SendToFlutter("READY");                  // Notify Flutter app that AR is ready

        // Wait for next frame
        yield return new WaitForEndOfFrame();

        Debug.Log("[ARSessionController] Sending BODY_DETECTED to Flutter."); // Log message
        FlutterCommunication.SendToFlutter("BODY_DETECTED");                  // Simulate body detection (unlock UI)
    }

    // Called when app is paused (e.g., minimized or switched)
    void OnApplicationPause(bool paused)
    {
        if (!paused) return;             // If app is resumed, do nothing here

        _initialized = false;            // Reset initialization flag

        StartCoroutine(ReinitOnResume()); // Restart initialization process
    }

    // Coroutine to reinitialize AR after app resumes
    IEnumerator ReinitOnResume()
    {
        yield return new WaitForSeconds(1.5f); // Wait before restarting (avoid crash/glitch)

        yield return StartCoroutine(Start());  // Call Start() coroutine again
    }
}
