using UnityEngine;
using FlutterUnityIntegration;

public class FlutterCommunication : MonoBehaviour
{
    // This function is called by Flutter using controller.postMessage
    public void LoadProductModel(string modelName)
    {
        Debug.Log("Loading model: " + modelName);
        // Logic to swap 3D clothes on the avatar
        GameObject model = Resources.Load<GameObject>("Clothes/" + modelName);
        Instantiate(model, Vector3.zero, Quaternion.identity);
    }

    // Call this to send data back to Flutter
    public void SendFitDataToFlutter(string data)
    {
        UnityMessageManager.Instance.SendMessageToFlutter(data);
    }
}
