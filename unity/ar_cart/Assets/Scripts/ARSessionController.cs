using System.Collections;
using UnityEngine;
using UnityEngine.XR.ARFoundation;

/// <summary>
/// ARSessionController — Minimal entry point for the AR scene.
/// Waits briefly for UnityMessageManager to connect, then tells Flutter it's READY.
/// Also immediately sends BODY_DETECTED so the Flutter UI unlocks to send LoadProduct.
/// </summary>
[RequireComponent(typeof(ARSession))]
public class ARSessionController : MonoBehaviour
{
    private bool _initialized = false;

    IEnumerator Start()
    {
        if (_initialized) yield break;
        _initialized = true;

        // Short delay to let UnityMessageManager finish connecting to Flutter
        yield return new WaitForSeconds(0.6f);

        Debug.Log("[ARSessionController] Sending READY to Flutter.");
        FlutterCommunication.SendToFlutter("READY");

        // Wait one frame, then send BODY_DETECTED so Flutter unlocks LoadProduct
        yield return new WaitForEndOfFrame();
        Debug.Log("[ARSessionController] Sending BODY_DETECTED to Flutter.");
        FlutterCommunication.SendToFlutter("BODY_DETECTED");
    }

    void OnApplicationPause(bool paused)
    {
        if (!paused) return;
        _initialized = false;
        StartCoroutine(ReinitOnResume());
    }

    IEnumerator ReinitOnResume()
    {
        yield return new WaitForSeconds(1.5f);
        yield return StartCoroutine(Start());
    }
}
