using UnityEngine;                         // Core Unity library
using FlutterUnityIntegration;            // Package to communicate with Flutter

/// <summary>
/// FlutterCommunication — Acts as a bridge between Flutter and Unity.
/// Receives messages from Flutter and sends responses back.
/// </summary>

public class FlutterCommunication : MonoBehaviour
{
    // ── REFERENCES ─────────────────────────────────────────

    [Header("References")]                 // Inspector section label

    [SerializeField] 
    private ARCoordinator coordinator;    // Reference to ARCoordinator script

    // Singleton instance (only one object should exist)
    private static FlutterCommunication _instance;

    // ── UNITY LIFECYCLE ───────────────────────────────────

    void Awake()
    {
        // If another instance already exists → destroy this one
        if (_instance != null && _instance != this)
        {
            Debug.LogWarning("[FlutterComm] Duplicate instance destroyed.");
            Destroy(gameObject);
            return;
        }

        _instance = this; // Assign singleton

        // Check if ARCoordinator is connected
        if (coordinator == null)
            Debug.LogError("[FlutterComm] ARCoordinator not assigned!");

        // IMPORTANT: GameObject name must match Flutter postMessage target
        if (gameObject.name != "FlutterComm")
            Debug.LogError($"[FlutterComm] GameObject must be named 'FlutterComm'!");
    }

    void OnDestroy()
    {
        // Reset instance when object is destroyed
        if (_instance == this) _instance = null;
    }

    // ── INCOMING: FLUTTER → UNITY ─────────────────────────

    /// Flutter calls this:
    /// postMessage('FlutterComm', 'LoadProduct', '{"id":"...","url":"..."}')
    public void LoadProduct(string json)
    {
        try
        {
            // Convert JSON string to object
            var data = JsonUtility.FromJson<LoadProductPayload>(json);

            // Validate URL
            if (string.IsNullOrEmpty(data.url))
            {
                Debug.LogError("[FlutterComm] Missing URL.");
                SendToFlutter("MODEL_ERROR:missing_url");
                return;
            }

            Debug.Log($"[FlutterComm] LoadProduct: {data.id}");

            // Call ARCoordinator to load model
            coordinator.LoadProduct(data.id ?? "unknown", data.url);
        }
        catch (System.Exception ex)
        {
            Debug.LogError("[FlutterComm] JSON parse error: " + ex.Message);
            SendToFlutter("MODEL_ERROR:parse_failed");
        }
    }

    /// Flutter: postMessage('FlutterComm', 'SetSize', 'M')
    public void SetSize(string sizeLabel)
    {
        if (string.IsNullOrEmpty(sizeLabel))
        {
            Debug.LogWarning("[FlutterComm] Empty size.");
            return;
        }

        Debug.Log("[FlutterComm] SetSize: " + sizeLabel);

        // Pass size to ARCoordinator
        coordinator.SetSize(sizeLabel);
    }

    /// Flutter: postMessage('FlutterComm', 'SetView', 'front/back')
    public void SetView(string view)
    {
        // Convert string → boolean
        bool isFront = view.Trim().ToLower() != "back";

        Debug.Log("[FlutterComm] SetView: " + (isFront ? "front" : "back"));

        // Pass view to ARCoordinator
        coordinator.SetView(isFront);
    }

    /// Flutter: postMessage('FlutterComm', 'TakeScreenshot', '')
    public void TakeScreenshot(string _)
    {
        Debug.Log("[FlutterComm] Screenshot requested.");

        // Call ARCoordinator screenshot
        coordinator.TakeScreenshot();
    }

    /// Flutter: postMessage('FlutterComm', 'ClearCache', '')
    public void ClearCache(string _)
    {
        coordinator.ClearCache(); // Clear stored models
    }

    // ── OUTGOING: UNITY → FLUTTER ─────────────────────────

    /// Send message back to Flutter
    public static void SendToFlutter(string message)
    {
        // If no instance exists → fail
        if (_instance == null)
        {
            Debug.LogWarning("[FlutterComm] No instance.");
            return;
        }

        // If communication system not ready
        if (UnityMessageManager.Instance == null)
        {
            Debug.LogWarning("[FlutterComm] MessageManager not ready.");
            return;
        }

        Debug.Log("[Unity → Flutter] " + message);

        // Send message to Flutter
        UnityMessageManager.Instance.SendMessageToFlutter(message);
    }

    // ── DATA CLASS ────────────────────────────────────────

    [System.Serializable]
    private class LoadProductPayload
    {
        public string id;   // Product ID
        public string url;  // Model URL (.glb file)
    }
}
