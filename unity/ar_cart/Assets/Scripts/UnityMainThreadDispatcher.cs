using System;                          // For Action delegate
using System.Collections.Generic;      // For Queue collection
using UnityEngine;                     // Unity core library

/// <summary>
/// UnityMainThreadDispatcher — Helps run background-thread code safely on Unity main thread.
/// </summary>
public class UnityMainThreadDispatcher : MonoBehaviour
{
    // Singleton instance (only one dispatcher allowed)
    private static UnityMainThreadDispatcher _instance;

    // Queue to store actions that need to run on main thread
    private readonly Queue<Action> _queue = new Queue<Action>();

    // Lock object for thread safety
    private readonly object _lock = new object();

    // ── SINGLETON ACCESS ───────────────────────────────────

    public static UnityMainThreadDispatcher Instance
    {
        get
        {
            // If instance not created yet
            if (_instance == null)
            {
                // Create new GameObject
                var go = new GameObject("[MainThreadDispatcher]");

                // Attach this script to it
                _instance = go.AddComponent<UnityMainThreadDispatcher>();

                // Prevent destruction when scene changes
                DontDestroyOnLoad(go);
            }
            return _instance;
        }
    }

    // ── UNITY LIFECYCLE ───────────────────────────────────

    void Awake()
    {
        // If another instance exists → destroy duplicate
        if (_instance != null && _instance != this)
        {
            Destroy(gameObject);
            return;
        }

        _instance = this;

        // Keep object alive across scenes
        DontDestroyOnLoad(gameObject);
    }

    // Runs every frame
    void Update()
    {
        // Lock queue to prevent thread conflicts
        lock (_lock)
        {
            // Execute all queued actions
            while (_queue.Count > 0)
            {
                _queue.Dequeue().Invoke(); // Run action
            }
        }
    }

    // ── PUBLIC FUNCTION ───────────────────────────────────

    /// <summary>
    /// Add action to queue (from background thread)
    /// </summary>
    public static void Enqueue(Action action)
    {
        if (action == null) return; // Ignore null

        // Lock queue before modifying
        lock (Instance._lock)
        {
            Instance._queue.Enqueue(action); // Add to queue
        }
    }
}
