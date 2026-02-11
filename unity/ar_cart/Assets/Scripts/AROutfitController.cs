using UnityEngine;
using FlutterUnityWidget;
using System.Collections.Generic;

public class AROutfitController : MonoBehaviour
{
    public List<GameObject> clothingPrefabs; // Assign your 3D models here in the Inspector
    private GameObject currentOutfit;

    // This method is called by Flutter: controller.postMessage('GameObject', 'ChangeOutfit', 'outfit_id')
    public void ChangeOutfit(string outfitId)
    {
        // Remove current outfit if it exists
        if (currentOutfit != null) Destroy(currentOutfit);

        // Find and instantiate the new outfit from the list
        GameObject prefab = clothingPrefabs.Find(p => p.name == outfitId);
        if (prefab != null)
        {
            currentOutfit = Instantiate(prefab, Vector3.zero, Quaternion.identity);
            // Logic to snap the outfit to the AR Human Body Tracker
            currentOutfit.transform.parent = GameObject.FindWithTag("ARHuman").transform;
        }
    }

    // Call this to notify Flutter that the fit is successful
    public void NotifyFitSuccess()
    {
        UnityMessageManager.Instance.SendMessageToFlutter("FIT_SUCCESS");
    }
}
