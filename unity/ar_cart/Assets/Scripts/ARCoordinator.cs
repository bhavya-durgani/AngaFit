using System;
using System.Collections;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;
using GLTFast;

/// <summary>
/// ARCoordinator — Single-file brains for the AngaFit AR Try-On feature.
///
/// Responsibilities:
///   • Download .glb clothing models from a direct URL (or cached file)
///   • Place the model in front of the camera at a sensible world position
///   • Handle size scaling (S/M/L/XL) and front/back view toggling
///   • Report progress & events back to Flutter via FlutterCommunication
///   • Take screenshots and return the file path to Flutter
///
/// Does NOT require body tracking or native Android plugins.
/// </summary>
public class ARCoordinator : MonoBehaviour
{
    // ── Inspector ───────────────────────────────────────────────────────────
    [Header("Model Placement")]
    [Tooltip("Distance in front of the camera where the outfit is placed.")]
    public float modelDistance = 2.5f;

    [Tooltip("Vertical offset from camera eye level (negative = lower).")]
    public float modelVerticalOffset = -0.8f;

    [Header("Sizing")]
    public float[] sizeScales = { 0.90f, 1.00f, 1.10f, 1.22f }; // S, M, L, XL
    private static readonly string[] SizeLabels = { "S", "M", "L", "XL" };

    [Header("Cache")]
    public float maxCacheMB = 200f;

    // ── Private State ───────────────────────────────────────────────────────
    private GameObject _activeModel;
    private Camera     _arCamera;
    private int        _currentSizeIndex = 1;  // M
    private bool       _isFrontView = true;
    private bool       _isDownloading = false;

    private string CacheDir => Path.Combine(Application.persistentDataPath, "model_cache");
    private string ScreenDir => Path.Combine(Application.persistentDataPath, "screenshots");

    // ── Unity Lifecycle ─────────────────────────────────────────────────────

    void Awake()
    {
        Directory.CreateDirectory(CacheDir);
        Directory.CreateDirectory(ScreenDir);
        _arCamera = Camera.main;
        if (_arCamera == null)
            Debug.LogWarning("[ARCoordinator] No main camera found. Model placement may be wrong.");
    }

    // ── Public API (called by FlutterCommunication) ─────────────────────────

    /// <summary>Load a clothing product from a direct glb URL.</summary>
    public void LoadProduct(string modelId, string url)
    {
        if (_isDownloading)
        {
            Debug.LogWarning("[ARCoordinator] Already downloading — ignoring duplicate LoadProduct.");
            return;
        }
        if (string.IsNullOrEmpty(url))
        {
            Debug.LogError("[ARCoordinator] LoadProduct called with empty URL.");
            FlutterCommunication.SendToFlutter("MODEL_ERROR:empty_url");
            return;
        }

        StartCoroutine(LoadModelCoroutine(modelId, url));
    }

    /// <summary>Set size by label: "S", "M", "L", "XL".</summary>
    public void SetSize(string sizeLabel)
    {
        int idx = Array.IndexOf(SizeLabels, sizeLabel.ToUpper());
        if (idx < 0) { Debug.LogWarning("[ARCoordinator] Unknown size: " + sizeLabel); return; }
        _currentSizeIndex = idx;
        ApplyScaleAndView();
    }

    /// <summary>Toggle front (0°) or back (180°) view.</summary>
    public void SetView(bool isFront)
    {
        _isFrontView = isFront;
        ApplyScaleAndView();
    }

    /// <summary>Capture current frame and send path back to Flutter.</summary>
    public void TakeScreenshot()
    {
        StartCoroutine(ScreenshotCoroutine());
    }

    /// <summary>Clear the local model cache.</summary>
    public void ClearCache()
    {
        if (_isDownloading) { Debug.LogWarning("[ARCoordinator] Cannot clear cache while downloading."); return; }
        if (Directory.Exists(CacheDir)) { Directory.Delete(CacheDir, true); Directory.CreateDirectory(CacheDir); }
        FlutterCommunication.SendToFlutter("CACHE_CLEARED");
    }

    // ── Model Loading ────────────────────────────────────────────────────────

    private IEnumerator LoadModelCoroutine(string modelId, string url)
    {
        _isDownloading = true;
        string cachePath = Path.Combine(CacheDir, SanitizeFileName(modelId) + ".glb");

        // Check cache
        if (File.Exists(cachePath) && new FileInfo(cachePath).Length > 0)
        {
            Debug.Log("[ARCoordinator] Cache hit: " + cachePath);
            FlutterCommunication.SendToFlutter("DOWNLOAD_PROGRESS:1.0");
            yield return StartCoroutine(InstantiateFromFile(modelId, cachePath));
        }
        else
        {
            yield return StartCoroutine(DownloadModel(modelId, url, cachePath));
        }

        _isDownloading = false;
    }

    private IEnumerator DownloadModel(string modelId, string url, string cachePath)
    {
        Debug.Log("[ARCoordinator] Downloading: " + url);

        using (var req = new UnityWebRequest(url, UnityWebRequest.kHttpVerbGET))
        {
            req.downloadHandler = new DownloadHandlerFile(cachePath);
            req.timeout = 120;
            req.SendWebRequest();

            while (!req.isDone)
            {
                FlutterCommunication.SendToFlutter($"DOWNLOAD_PROGRESS:{req.downloadProgress:F2}");
                yield return null;
            }

            if (req.result != UnityWebRequest.Result.Success)
            {
                if (File.Exists(cachePath)) File.Delete(cachePath);
                Debug.LogError("[ARCoordinator] Download failed: " + req.error);
                FlutterCommunication.SendToFlutter("MODEL_ERROR:" + req.error);
                yield break;
            }

            var fi = new FileInfo(cachePath);
            if (fi.Length == 0)
            {
                File.Delete(cachePath);
                FlutterCommunication.SendToFlutter("MODEL_ERROR:empty_download");
                yield break;
            }
        }

        FlutterCommunication.SendToFlutter("DOWNLOAD_PROGRESS:1.0");
        yield return StartCoroutine(InstantiateFromFile(modelId, cachePath));
    }

    private IEnumerator InstantiateFromFile(string modelId, string filePath)
    {
        if (!File.Exists(filePath))
        {
            FlutterCommunication.SendToFlutter("MODEL_ERROR:file_not_found");
            yield break;
        }

        var gltf = new GltfImport();
        var loadTask = gltf.Load("file://" + filePath);
        yield return new WaitUntil(() => loadTask.IsCompleted);

        if (!loadTask.Result)
        {
            File.Delete(filePath); // Delete corrupt cache entry
            FlutterCommunication.SendToFlutter("MODEL_ERROR:parse_failed");
            yield break;
        }

        // Destroy previous model
        if (_activeModel != null) { Destroy(_activeModel); _activeModel = null; }

        _activeModel = new GameObject("Outfit_" + modelId);
        var instantiateTask = gltf.InstantiateMainSceneAsync(_activeModel.transform);
        yield return new WaitUntil(() => instantiateTask.IsCompleted);

        if (!instantiateTask.Result)
        {
            Destroy(_activeModel);
            _activeModel = null;
            FlutterCommunication.SendToFlutter("MODEL_ERROR:instantiate_failed");
            yield break;
        }

        PlaceModelInView();
        ApplyScaleAndView();

        FlutterCommunication.SendToFlutter("OUTFIT_APPLIED");
        Debug.Log("[ARCoordinator] Outfit applied: " + modelId);
    }

    // ── Model Positioning ────────────────────────────────────────────────────

    private void PlaceModelInView()
    {
        if (_activeModel == null) return;

        if (_arCamera != null)
        {
            Vector3 camPos = _arCamera.transform.position;
            Vector3 forward = Vector3.ProjectOnPlane(_arCamera.transform.forward, Vector3.up).normalized;
            _activeModel.transform.position = camPos
                + forward * modelDistance
                + Vector3.up * modelVerticalOffset;
            _activeModel.transform.rotation = Quaternion.LookRotation(-forward, Vector3.up);
        }
        else
        {
            // Fallback: place at scene origin
            _activeModel.transform.position = new Vector3(0, -0.8f, 2.5f);
            _activeModel.transform.rotation = Quaternion.identity;
        }
    }

    private void ApplyScaleAndView()
    {
        if (_activeModel == null) return;

        float scale = sizeScales[Mathf.Clamp(_currentSizeIndex, 0, sizeScales.Length - 1)];
        _activeModel.transform.localScale = Vector3.one * scale;

        // Rotate for front/back view
        Vector3 euler = _activeModel.transform.eulerAngles;
        euler.y = _isFrontView ? 0f : 180f;
        _activeModel.transform.eulerAngles = euler;
    }

    // ── Screenshot ───────────────────────────────────────────────────────────

    private IEnumerator ScreenshotCoroutine()
    {
        yield return new WaitForEndOfFrame();

        string filePath = Path.Combine(ScreenDir,
            "angafit_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".png");

        Texture2D tex = null;
        try
        {
            tex = new Texture2D(Screen.width, Screen.height, TextureFormat.RGB24, false);
            tex.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);
            tex.Apply();
        }
        catch (Exception ex)
        {
            Debug.LogError("[ARCoordinator] Screenshot ReadPixels failed: " + ex.Message);
            if (tex != null) Destroy(tex);
            FlutterCommunication.SendToFlutter("SCREENSHOT_ERROR:read_pixels_failed");
            yield break;
        }

        byte[] bytes = tex.EncodeToPNG();
        Destroy(tex);

        bool ok = false;
        string err = null;
        var thread = new System.Threading.Thread(() =>
        {
            try { File.WriteAllBytes(filePath, bytes); ok = true; }
            catch (Exception ex) { err = ex.Message; }
        });
        thread.Start();
        yield return new WaitUntil(() => !thread.IsAlive);

        if (ok)
        {
            Debug.Log("[ARCoordinator] Screenshot saved: " + filePath);
            FlutterCommunication.SendToFlutter("SCREENSHOT:" + filePath);
        }
        else
        {
            Debug.LogError("[ARCoordinator] Screenshot write failed: " + err);
            FlutterCommunication.SendToFlutter("SCREENSHOT_ERROR:write_failed");
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private static string SanitizeFileName(string name)
    {
        foreach (char c in Path.GetInvalidFileNameChars())
            name = name.Replace(c, '_');
        return name;
    }
}
