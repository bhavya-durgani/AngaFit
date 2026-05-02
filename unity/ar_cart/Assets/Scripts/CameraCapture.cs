using System;                         // For DateTime and Exception handling
using System.Collections;             // For IEnumerator (coroutines)
using System.IO;                      // For file handling (save/delete)
using UnityEngine;                    // Unity core library

/// <summary>
/// CameraCapture — Takes a screenshot of the AR view, saves to storage,
/// and returns file path back to Flutter.
/// </summary>
public class CameraCapture : MonoBehaviour
{
    // ── SETTINGS ─────────────────────────────────────────────

    [Header("Settings")]              // Inspector section header

    [Range(0, 100)]                  // Restrict value between 0–100 in Inspector
    [Tooltip("JPEG quality 0-100 (PNG is always lossless).")]
    public int jpegQuality = 90;     // Quality of JPEG image

    [Tooltip("If true, save as PNG. If false, save as JPEG.")]
    public bool savePNG = true;      // Choose image format

    // Folder name for saving screenshots
    private const string ScreenshotSubDir = "screenshots";

    // Full path where screenshots will be stored
    private string ScreenshotDir => Path.Combine(
        Application.persistentDataPath,  // App storage path
        ScreenshotSubDir                 // screenshots folder
    );

    // Prevent multiple screenshots at same time
    private bool isCaptureInProgress = false;

    // ── UNITY LIFECYCLE ─────────────────────────────────────

    void Awake()
    {
        // Create folder if it doesn't exist
        Directory.CreateDirectory(ScreenshotDir);
    }

    // ── PUBLIC FUNCTION ─────────────────────────────────────

    /// <summary>
    /// Capture screenshot and return file path
    /// </summary>
    public void Capture(Action<string> onComplete)
    {
        // If already capturing → ignore
        if (isCaptureInProgress)
        {
            Debug.LogWarning("[CameraCapture] Capture already in progress.");
            return;
        }

        // Start coroutine
        StartCoroutine(CaptureRoutine(onComplete));
    }

    // ── CORE LOGIC ──────────────────────────────────────────

    private IEnumerator CaptureRoutine(Action<string> onComplete)
    {
        isCaptureInProgress = true;  // Lock capture

        // Wait till frame rendering is complete
        yield return new WaitForEndOfFrame();

        // Create file name with timestamp
        string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
        string ext = savePNG ? "png" : "jpg";

        // Final file path
        string filePath = Path.Combine(
            ScreenshotDir,
            $"angafit_{timestamp}.{ext}"
        );

        Texture2D screenshot = null;

        try
        {
            // Create texture same size as screen
            screenshot = new Texture2D(
                Screen.width,
                Screen.height,
                TextureFormat.RGB24,
                false
            );

            // Capture pixels from screen
            screenshot.ReadPixels(
                new Rect(0, 0, Screen.width, Screen.height),
                0, 0
            );

            screenshot.Apply(); // Apply changes
        }
        catch (Exception ex)
        {
            Debug.LogError("[CameraCapture] ReadPixels failed: " + ex.Message);

            // Free memory if texture created
            if (screenshot != null) Destroy(screenshot);

            isCaptureInProgress = false;

            // Return failure
            onComplete?.Invoke(null);
            yield break;
        }

        byte[] bytes;

        try
        {
            // Convert image to PNG or JPEG
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
            // Always free memory
            Destroy(screenshot);
        }

        // ── SAVE FILE (BACKGROUND THREAD) ───────────────────

        bool writeSuccess = false;
        string writeError = null;

        // Create new thread for file writing
        var writeThread = new System.Threading.Thread(() =>
        {
            try
            {
                File.WriteAllBytes(filePath, bytes); // Save file
                writeSuccess = true;
            }
            catch (Exception ex)
            {
                writeError = ex.Message;
            }
        });

        writeThread.Start();

        // Wait until file writing finishes
        yield return new WaitUntil(() => !writeThread.IsAlive);

        isCaptureInProgress = false;  // Unlock capture

        if (writeSuccess)
        {
            Debug.Log("[CameraCapture] Saved to: " + filePath);

            // Return file path to Flutter
            onComplete?.Invoke(filePath);
        }
        else
        {
            Debug.LogError("[CameraCapture] Write failed: " + writeError);

            onComplete?.Invoke(null);
        }
    }

    // ── EXTRA FUNCTIONS ─────────────────────────────────────

    /// <summary>
    /// Get all screenshots (for gallery)
    /// </summary>
    public string[] GetAllScreenshots()
    {
        if (!Directory.Exists(ScreenshotDir))
            return new string[0];

        // Get PNG and JPG files
        var pngs = Directory.GetFiles(ScreenshotDir, "*.png");
        var jpgs = Directory.GetFiles(ScreenshotDir, "*.jpg");

        // Combine both
        var all = new string[pngs.Length + jpgs.Length];
        pngs.CopyTo(all, 0);
        jpgs.CopyTo(all, pngs.Length);

        return all;
    }

    /// <summary>
    /// Delete all screenshots
    /// </summary>
    public void ClearScreenshots()
    {
        if (Directory.Exists(ScreenshotDir))
        {
            Directory.Delete(ScreenshotDir, true);   // Delete folder
            Directory.CreateDirectory(ScreenshotDir); // Recreate empty folder
        }
    }
}
