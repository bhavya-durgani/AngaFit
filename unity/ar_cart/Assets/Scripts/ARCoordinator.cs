using System; // Basic C# utilities (DateTime, Exception)
using System.Collections; // For IEnumerator (coroutines)
using System.IO; // File handling
using UnityEngine; // Unity engine
using UnityEngine.Networking; // For downloading files
using GLTFast; // To load .glb 3D models

// Main class controlling AR try-on system
public class ARCoordinator : MonoBehaviour
{
    // ───────────── Inspector Variables (Editable in Unity) ─────────────

    [Header("Model Placement")]
    public float modelDistance = 2.5f; // Distance from camera
    public float modelVerticalOffset = -0.8f; // Move model down slightly

    [Header("Sizing")]
    public float[] sizeScales = { 0.90f, 1.00f, 1.10f, 1.22f }; // S, M, L, XL scale
    private static readonly string[] SizeLabels = { "S", "M", "L", "XL" }; // Labels

    [Header("Cache")]
    public float maxCacheMB = 200f; // Max cache size

    // ───────────── Private Variables ─────────────

    private GameObject _activeModel; // Current model
    private Camera _arCamera; // Main camera
    private int _currentSizeIndex = 1; // Default size (M)
    private bool _isFrontView = true; // Front view toggle
    private bool _isDownloading = false; // Prevent duplicate downloads

    // Folder paths
    private string CacheDir => Path.Combine(Application.persistentDataPath, "model_cache");
    private string ScreenDir => Path.Combine(Application.persistentDataPath, "screenshots");

    // ───────────── Unity Lifecycle ─────────────

    void Awake()
    {
        Directory.CreateDirectory(CacheDir); // Create cache folder
        Directory.CreateDirectory(ScreenDir); // Create screenshot folder

        _arCamera = Camera.main; // Get main camera

        if (_arCamera == null)
            Debug.LogWarning("No main camera found");
    }

    // ───────────── Public API (Called from Flutter) ─────────────

    public void LoadProduct(string modelId, string url)
    {
        if (_isDownloading) return; // Prevent multiple downloads

        if (string.IsNullOrEmpty(url))
        {
            FlutterCommunication.SendToFlutter("MODEL_ERROR:empty_url"); // Send error
            return;
        }

        StartCoroutine(LoadModelCoroutine(modelId, url)); // Start loading
    }

    public void SetSize(string sizeLabel)
    {
        int idx = Array.IndexOf(SizeLabels, sizeLabel.ToUpper()); // Find index

        if (idx < 0) return; // Invalid size

        _currentSizeIndex = idx; // Set size
        ApplyScaleAndView(); // Apply changes
    }

    public void SetView(bool isFront)
    {
        _isFrontView = isFront; // Set front/back
        ApplyScaleAndView(); // Apply rotation
    }

    public void TakeScreenshot()
    {
        StartCoroutine(ScreenshotCoroutine()); // Start screenshot
    }

    public void ClearCache()
    {
        if (_isDownloading) return; // Prevent during download

        if (Directory.Exists(CacheDir))
        {
            Directory.Delete(CacheDir, true); // Delete cache
            Directory.CreateDirectory(CacheDir); // Recreate
        }

        FlutterCommunication.SendToFlutter("CACHE_CLEARED"); // Notify Flutter
    }

    // ───────────── Model Loading ─────────────

    private IEnumerator LoadModelCoroutine(string modelId, string url)
    {
        _isDownloading = true; // Mark downloading

        string cachePath = Path.Combine(CacheDir, modelId + ".glb"); // File path

        if (File.Exists(cachePath)) // Check cache
        {
            yield return StartCoroutine(InstantiateFromFile(modelId, cachePath));
        }
        else
        {
            yield return StartCoroutine(DownloadModel(modelId, url, cachePath));
        }

        _isDownloading = false; // Done
    }

    private IEnumerator DownloadModel(string modelId, string url, string cachePath)
    {
        using (var req = new UnityWebRequest(url, UnityWebRequest.kHttpVerbGET))
        {
            req.downloadHandler = new DownloadHandlerFile(cachePath); // Save file
            req.SendWebRequest();

            while (!req.isDone)
            {
                FlutterCommunication.SendToFlutter($"DOWNLOAD_PROGRESS:{req.downloadProgress}");
                yield return null; // Wait
            }

            if (req.result != UnityWebRequest.Result.Success)
            {
                FlutterCommunication.SendToFlutter("MODEL_ERROR");
                yield break;
            }
        }

        yield return StartCoroutine(InstantiateFromFile(modelId, cachePath));
    }

    private IEnumerator InstantiateFromFile(string modelId, string filePath)
    {
        var gltf = new GltfImport(); // Create loader

        var loadTask = gltf.Load("file://" + filePath); // Load file
        yield return new WaitUntil(() => loadTask.IsCompleted);

        if (!loadTask.Result)
        {
            FlutterCommunication.SendToFlutter("MODEL_ERROR:parse_failed");
            yield break;
        }

        if (_activeModel != null)
            Destroy(_activeModel); // Remove old model

        _activeModel = new GameObject("Outfit_" + modelId); // Create object

        var instantiateTask = gltf.InstantiateMainSceneAsync(_activeModel.transform);
        yield return new WaitUntil(() => instantiateTask.IsCompleted);

        PlaceModelInView(); // Position model
        ApplyScaleAndView(); // Apply scale + rotation

        FlutterCommunication.SendToFlutter("OUTFIT_APPLIED"); // Notify Flutter
    }

    // ───────────── Model Positioning ─────────────

    private void PlaceModelInView()
    {
        if (_activeModel == null) return;

        if (_arCamera != null)
        {
            Vector3 camPos = _arCamera.transform.position; // Camera position
            Vector3 forward = Vector3.ProjectOnPlane(_arCamera.transform.forward, Vector3.up);

            _activeModel.transform.position =
                camPos + forward * modelDistance + Vector3.up * modelVerticalOffset;

            _activeModel.transform.rotation = Quaternion.LookRotation(-forward);
        }
        else
        {
            _activeModel.transform.position = new Vector3(0, -0.8f, 2.5f); // Default
        }
    }

    private void ApplyScaleAndView()
    {
        if (_activeModel == null) return;

        float scale = sizeScales[Mathf.Clamp(_currentSizeIndex, 0, sizeScales.Length - 1)];
        _activeModel.transform.localScale = Vector3.one * scale; // Apply size

        Vector3 euler = _activeModel.transform.eulerAngles;
        euler.y = _isFrontView ? 0f : 180f; // Rotate front/back
        _activeModel.transform.eulerAngles = euler;
    }

    // ───────────── Screenshot ─────────────

    private IEnumerator ScreenshotCoroutine()
    {
        yield return new WaitForEndOfFrame(); // Wait for frame render

        string filePath = Path.Combine(ScreenDir, "angafit_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".png");

        Texture2D tex = new Texture2D(Screen.width, Screen.height);
        tex.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);
        tex.Apply();

        byte[] bytes = tex.EncodeToPNG(); // Convert to PNG
        Destroy(tex);

        File.WriteAllBytes(filePath, bytes); // Save file

        FlutterCommunication.SendToFlutter("SCREENSHOT:" + filePath); // Send path
    }

    // ───────────── Helper ─────────────

    private static string SanitizeFileName(string name)
    {
        foreach (char c in Path.GetInvalidFileNameChars())
            name = name.Replace(c, '_'); // Replace invalid chars

        return name;
    }
}
