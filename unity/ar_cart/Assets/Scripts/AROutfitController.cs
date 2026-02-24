using UnityEngine;
using UnityEngine.Video; // Required for video playback
using System.Collections.Generic;
using FlutterUnityIntegration;

public class AROutfitController : MonoBehaviour
{
    public VideoPlayer backgroundVideo; // Drag your Video Player here
    public List<GameObject> clothingPrefabs;
    private GameObject currentOutfit;

    // 1. Called by Flutter to play the recorded video
    public void SetVideoBackground(string path)
    {
        // Add file prefix so Unity can read the local phone storage
        backgroundVideo.url = "file://" + path;
        backgroundVideo.isLooping = true;
        backgroundVideo.Play();
    }

    // 2. Called by Flutter to show the specific dress
    public void ChangeOutfit(string outfitId)
    {
        if (currentOutfit != null) Destroy(currentOutfit);

        GameObject prefab = clothingPrefabs.Find(p => p.name == outfitId);
        if (prefab != null) {
            // Position the dress in the center of the screen
            // X:0 (Center), Y:-1 (Shoulder height), Z:5 (Distance from camera)
            currentOutfit = Instantiate(prefab, new Vector3(0, -1f, 5f), Quaternion.identity);
        }
    }
}
