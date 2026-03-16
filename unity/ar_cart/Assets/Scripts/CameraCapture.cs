using System;
using System.Collections;
using System.IO;
using UnityEngine;

/// <summary>
/// CameraCapture — Takes a screenshot of the AR view, saves to persistentDataPath,
/// and returns the file path via callback (which FlutterCommunication forwards to Flutter).
/// </summary>
public class CameraCapture : MonoBehaviour
{
    [Header("Settings")]
    [Range(0, 100)]
    [Tooltip("JPEG quality 0-100 (PNG is always lossless).")]
    public int jpegQuality = 90;

    [Tooltip("If true, save as PNG. If false, save as JPEG.")]
    public bool savePNG = true;

    private const string ScreenshotSubDir = "screenshots";
    private string ScreenshotDir => Path.Combine(Application.persistentDataPath, ScreenshotSubDir);

    // FIX: Track ongoing capture to prevent overlapping coroutines
    private bool isCaptureInProgress = false;

    void Awake()
    {
        Directory.CreateDirectory(ScreenshotDir);
    }

    /// <summary>
    /// Captures the current frame and saves it to disk.
    /// onComplete is invoked with the absolute file path when done, or null on failure.
    /// </summary>
    public void Capture(Action<string> onComplete)
    {
        // FIX: Prevent multiple simultaneous captures (e.g. user taps button twice)
        if (isCaptureInProgress)
        {
            Debug.LogWarning("[CameraCapture] Capture already in progress, ignoring duplicate request.");
            return;
        }
        StartCoroutine(CaptureRoutine(onComplete));
    }

    private IEnumerator CaptureRoutine(Action<string> onComplete)
    {
        isCaptureInProgress = true;

        // Wait for end of frame to ensure AR camera has rendered
        yield return new WaitForEndOfFrame();

        string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
        string ext = savePNG ? "png" : "jpg";
        string filePath = Path.Combine(ScreenshotDir, $"angafit_{timestamp}.{ext}");

        Texture2D screenshot = null;

        try
        {
            screenshot = new Texture2D(
                Screen.width,
                Screen.height,
                TextureFormat.RGB24,
                false
            );

            screenshot.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);
            screenshot.Apply();
        }
        catch (Exception ex)
        {
            Debug.LogError("[CameraCapture] ReadPixels failed: " + ex.Message);
            // FIX: Clean up texture if created before exception
            if (screenshot != null) Destroy(screenshot);
            isCaptureInProgress = false;
            onComplete?.Invoke(null);
            yield break;
        }

        byte[] bytes;
        try
        {
            bytes = savePNG
                ? screenshot.EncodeToPNG()
                : screenshot.EncodeToJPG(jpegQuality);
        }
        catch (Exception ex)
        {
            Debug.LogError("[CameraCapture] Encode failed: " + ex.Message);
            Destroy(screenshot);
            isCaptureInProgress = false;
            onComplete?.Invoke(null);
            yield break;
        }
        finally
        {
            // FIX: Always destroy texture to prevent memory leak,
            // even if encode succeeds (was already correct) or throws
            Destroy(screenshot);
        }

        // FIX: Run file write on a background thread to avoid freezing the AR frame
        // (writing large PNGs on main thread causes visible frame drop)
        bool writeSuccess = false;
        string writeError = null;

        var writeThread = new System.Threading.Thread(() =>
        {
            try
            {
                File.WriteAllBytes(filePath, bytes);
                writeSuccess = true;
            }
            catch (Exception ex)
            {
                writeError = ex.Message;
            }
        });
        writeThread.Start();

        // Wait for write to complete
        yield return new WaitUntil(() => !writeThread.IsAlive);

        isCaptureInProgress = false;    

        if (writeSuccess)
        {
            Debug.Log("[CameraCapture] Saved to: " + filePath);
            onComplete?.Invoke(filePath);
        }
        else
        {
            Debug.LogError("[CameraCapture] Write failed: " + writeError);
            onComplete?.Invoke(null);
        }
    }

    /// <summary>List all saved screenshots (for a gallery view in Flutter).</summary>
    public string[] GetAllScreenshots()
    {
        if (!Directory.Exists(ScreenshotDir)) return new string[0];

        // FIX: Return both PNG and JPEG screenshots, not just PNG
        var pngs  = Directory.GetFiles(ScreenshotDir, "*.png");
        var jpgs  = Directory.GetFiles(ScreenshotDir, "*.jpg");
        var all   = new string[pngs.Length + jpgs.Length];
        pngs.CopyTo(all, 0);
        jpgs.CopyTo(all, pngs.Length);
        return all;
    }

    /// <summary>Delete all saved screenshots.</summary>
    public void ClearScreenshots()
    {
        if (Directory.Exists(ScreenshotDir))
        {
            Directory.Delete(ScreenshotDir, true);
            Directory.CreateDirectory(ScreenshotDir);
        }
    }
}