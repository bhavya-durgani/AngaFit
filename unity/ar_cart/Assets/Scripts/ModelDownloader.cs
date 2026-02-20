using UnityEngine;
using UnityEngine.Networking;
using System.Collections;
using FlutterUnityIntegration;

public class ModelDownloader : MonoBehaviour
{
    private GameObject currentModel;

    // This is called by Flutter: controller.postMessage('ModelLoader', 'DownloadAndLoad', 'https://firebasestorage...')
    public void DownloadAndLoad(string url)
    {
        StartCoroutine(GetAssetBundle(url));
    }

    IEnumerator GetAssetBundle(string url)
    {
        UnityWebRequest www = UnityWebRequestAssetBundle.GetAssetBundle(url);
        yield return www.SendWebRequest();

        if (www.result != UnityWebRequest.Result.Success)
        {
            Debug.LogError("Download failed: " + www.error);
            UnityMessageManager.Instance.SendMessageToFlutter("DOWNLOAD_ERROR");
        }
        else
        {
            AssetBundle bundle = DownloadHandlerAssetBundle.GetContent(www);
            // Assuming your 3D model inside the bundle is named "ClothingItem"
            GameObject prefab = bundle.LoadAsset<GameObject>("ClothingItem");

            if (currentModel != null) Destroy(currentModel);

            currentModel = Instantiate(prefab);
            // Attach to the AR Body Tracker
            currentModel.transform.parent = GameObject.FindWithTag("ARHuman").transform;

            UnityMessageManager.Instance.SendMessageToFlutter("DOWNLOAD_SUCCESS");
            bundle.Unload(false);
        }
    }
}
