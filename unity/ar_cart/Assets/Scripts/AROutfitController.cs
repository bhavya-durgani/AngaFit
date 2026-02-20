using UnityEngine;
using UnityEngine.Video;
using FlutterUnityIntegration;
using System.Collections.Generic;

public class AROutfitController : MonoBehaviour
{
    public VideoPlayer videoBackground; // Assign a VideoPlayer in Inspector
    public List<GameObject> clothingPrefabs;
    private GameObject currentOutfit;

    // Called by Flutter to set the recorded video as background
    public void SetVideoBackground(string path)
    {
        videoBackground.url = path;
        videoBackground.Play();
    }

    public void ChangeOutfit(string outfitId)
    {
        if (currentOutfit != null) Destroy(currentOutfit);
        GameObject prefab = clothingPrefabs.Find(p => p.name == outfitId);
        if (prefab != null) {
            currentOutfit = Instantiate(prefab, Vector3.zero, Quaternion.identity);
            // In video mode, the outfit stays centered while the person in the video turns
            currentOutfit.transform.position = new Vector3(0, 0, 5);
        }
    }
}
