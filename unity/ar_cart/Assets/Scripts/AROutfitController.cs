using UnityEngine;
using UnityEngine.Video;
using System.Collections.Generic;
using FlutterUnityIntegration;

public class AROutfitController : MonoBehaviour
{
    public VideoPlayer videoPlayer; // Link this in the Inspector
    public List<GameObject> clothingPrefabs;
    private GameObject currentOutfit;

    // Flutter calls this with the path: /data/user/0/com.example.../video.mp4
    public void SetVideoBackground(string path)
    {
        // Ensure path starts with file:// for local files
        if (!path.StartsWith("file://")) {
            path = "file://" + path;
        }

        videoPlayer.url = path;
        videoPlayer.isLooping = true;
        videoPlayer.Play();

        Debug.Log("Playing recorded video from: " + path);
    }

    public void ChangeOutfit(string outfitId)
    {
        if (currentOutfit != null) Destroy(currentOutfit);

        GameObject prefab = clothingPrefabs.Find(p => p.name == outfitId);
        if (prefab != null) {
            // Position the outfit in front of the camera
            currentOutfit = Instantiate(prefab, new Vector3(0, -1, 5), Quaternion.identity);

            // Send message back to Flutter when ready
            UnityMessageManager.Instance.SendMessageToFlutter("LOADED");
        }
    }
}
