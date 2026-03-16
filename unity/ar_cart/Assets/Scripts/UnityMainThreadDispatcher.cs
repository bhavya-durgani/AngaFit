using System;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// UnityMainThreadDispatcher — Allows background threads (Android Java callbacks)
/// to safely schedule actions on the Unity main thread.
/// Place on a persistent GameObject in the scene.
/// </summary>
public class UnityMainThreadDispatcher : MonoBehaviour
{
    private static UnityMainThreadDispatcher _instance;
    private readonly Queue<Action> _queue = new Queue<Action>();
    private readonly object _lock = new object();

    public static UnityMainThreadDispatcher Instance
    {
        get
        {
            if (_instance == null)
            {
                var go = new GameObject("[MainThreadDispatcher]");
                _instance = go.AddComponent<UnityMainThreadDispatcher>();
                DontDestroyOnLoad(go);
            }
            return _instance;
        }
    }

    void Awake()
    {
        if (_instance != null && _instance != this) { Destroy(gameObject); return; }
        _instance = this;
        DontDestroyOnLoad(gameObject);
    }

    void Update()
    {
        lock (_lock)
        {
            while (_queue.Count > 0)
                _queue.Dequeue().Invoke();
        }
    }

    /// <summary>Queue an action to execute on the main thread at the next Update().</summary>
    public static void Enqueue(Action action)
    {
        if (action == null) return;
        lock (Instance._lock)
        {
            Instance._queue.Enqueue(action);
        }
    }
}
