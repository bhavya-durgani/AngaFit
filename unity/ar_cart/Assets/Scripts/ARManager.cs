using UnityEngine;
using UnityEngine.Video;
using System.Collections;
using GLTFast; // Requires the package from Step 1
using FlutterUnityIntegration;

public class ARManager : MonoBehaviour
{
    private GltfImport gltfImport;
    private GameObject currentModel;
    private VideoPlayer videoPlayer;

    void Awake()
    {
        // 1. Setup Video Player on the Camera via code
        videoPlayer = gameObject.AddComponent<VideoPlayer>();
        videoPlayer.renderMode = VideoRenderMode.CameraFarPlane;
        videoPlayer.targetCamera = GetComponent<Camera>();
        videoPlayer.isLooping = true;
    }

    // Called by Flutter: controller.postMessage('Main Camera', 'SetVideoBackground', path)
    public void SetVideoBackground(string path)
    {
        videoPlayer.url = "file://" + path;
        videoPlayer.Play();
    }

    // Called by Flutter: controller.postMessage('Main Camera', 'LoadCloudModel', url)
    public void LoadCloudModel(string url)
    {
        StartCoroutine(DownloadAndDisplayModel(url));
    }

    IEnumerator DownloadAndDisplayModel(string url)
    {
        if (currentModel != null) Destroy(currentModel);

        gltfImport = new GltfImport();
        var task = gltfImport.Load(url);

        yield return new WaitUntil(() => task.IsCompleted);

        if (task.Result)
        {
            currentModel = new GameObject("LoadedOutfit");
            gltfImport.InstantiateMainSceneAsync(currentModel.transform);

            // Position the model in front of the camera
            currentModel.transform.position = new Vector3(0, -1.2f, 3.5f);
            currentModel.transform.rotation = Quaternion.Euler(0, 180, 0);

            // Tell Flutter we are done
            UnityMessageManager.Instance.SendMessageToFlutter("LOADED");
        }
        else {
            Debug.LogError("Model Download Failed from URL: " + url);
        }
    }
}
