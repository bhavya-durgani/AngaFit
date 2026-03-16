using UnityEngine;
using FlutterUnityIntegration;

/// <summary>
/// FlutterCommunication — Routes postMessage calls from Flutter to ARCoordinator.
///
/// Flutter calls:
///   controller.postMessage('FlutterComm', 'LoadProduct', '{"id":"shirt_001","url":"https://..."}')
///   controller.postMessage('FlutterComm', 'SetSize',      'L')
///   controller.postMessage('FlutterComm', 'SetView',      'back')
///   controller.postMessage('FlutterComm', 'TakeScreenshot', '')
///   controller.postMessage('FlutterComm', 'ClearCache',   '')
///
/// IMPORTANT: The GameObject this script is attached to MUST be named exactly "FlutterComm".
/// </summary>
public class FlutterCommunication : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private ARCoordinator coordinator;

    // Singleton — allows any script to call SendToFlutter() statically
    private static FlutterCommunication _instance;

    void Awake()
    {
        if (_instance != null && _instance != this)
        {
            Debug.LogWarning("[FlutterComm] Duplicate instance destroyed.");
            Destroy(gameObject);
            return;
        }
        _instance = this;

        if (coordinator == null)
            Debug.LogError("[FlutterComm] ARCoordinator reference is not assigned!");

        if (gameObject.name != "FlutterComm")
            Debug.LogError($"[FlutterComm] GameObject must be named 'FlutterComm' but is '{gameObject.name}'. Flutter messages will NOT be received!");
    }

    void OnDestroy()
    {
        if (_instance == this) _instance = null;
    }

    // ── Incoming: Flutter → Unity ────────────────────────────────────────────

    /// <summary>Flutter: postMessage('FlutterComm', 'LoadProduct', '{"id":"...","url":"..."}')</summary>
    public void LoadProduct(string json)
    {
        try
        {
            var data = JsonUtility.FromJson<LoadProductPayload>(json);
            if (string.IsNullOrEmpty(data.url))
            {
                Debug.LogError("[FlutterComm] LoadProduct: missing 'url' in payload.");
                SendToFlutter("MODEL_ERROR:missing_url");
                return;
            }
            Debug.Log($"[FlutterComm] LoadProduct: id={data.id} url={data.url}");
            coordinator.LoadProduct(data.id ?? "unknown", data.url);
        }
        catch (System.Exception ex)
        {
            Debug.LogError("[FlutterComm] LoadProduct parse error: " + ex.Message);
            SendToFlutter("MODEL_ERROR:parse_failed");
        }
    }

    /// <summary>Flutter: postMessage('FlutterComm', 'SetSize', 'M')</summary>
    public void SetSize(string sizeLabel)
    {
        if (string.IsNullOrEmpty(sizeLabel)) { Debug.LogWarning("[FlutterComm] SetSize: empty label."); return; }
        Debug.Log("[FlutterComm] SetSize: " + sizeLabel);
        coordinator.SetSize(sizeLabel);
    }

    /// <summary>Flutter: postMessage('FlutterComm', 'SetView', 'front') or 'back'</summary>
    public void SetView(string view)
    {
        bool isFront = view.Trim().ToLower() != "back";
        Debug.Log("[FlutterComm] SetView: " + (isFront ? "front" : "back"));
        coordinator.SetView(isFront);
    }

    /// <summary>Flutter: postMessage('FlutterComm', 'TakeScreenshot', '')</summary>
    public void TakeScreenshot(string _)
    {
        Debug.Log("[FlutterComm] TakeScreenshot requested.");
        coordinator.TakeScreenshot();
    }

    /// <summary>Flutter: postMessage('FlutterComm', 'ClearCache', '')</summary>
    public void ClearCache(string _)
    {
        coordinator.ClearCache();
    }

    // ── Outgoing: Unity → Flutter ────────────────────────────────────────────

    /// <summary>Send a plain-string message back to Flutter.</summary>
    public static void SendToFlutter(string message)
    {
        if (_instance == null)
        {
            Debug.LogWarning("[FlutterComm] No instance — cannot send: " + message);
            return;
        }
        if (UnityMessageManager.Instance == null)
        {
            Debug.LogWarning("[FlutterComm] UnityMessageManager not ready — cannot send: " + message);
            return;
        }
        Debug.Log("[FlutterComm → Flutter] " + message);
        UnityMessageManager.Instance.SendMessageToFlutter(message);
    }

    // ── Data Types ───────────────────────────────────────────────────────────

    [System.Serializable]
    private class LoadProductPayload
    {
        public string id;
        public string url;
    }
}