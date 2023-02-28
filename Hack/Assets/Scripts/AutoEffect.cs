using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class AutoEffect : MonoBehaviour
{
    // Public variables
    public Canvas canvas;
    public TextMeshProUGUI text;
    public float distanceThreshold = 2.0f;
    public AudioClip sound;

    // Private variables
    private bool isInRange = false;
    private bool hasPlayedSound = false;
    private AudioSource audioSource;

    void Start()
    {
        // Disable the canvas and text at the start of the game
        canvas.enabled = false;
        text.enabled = false;

        // Get the AudioSource component
        audioSource = GetComponent<AudioSource>();
    }

    void Update()
    {
        // Check if the player is within the distance threshold
        float distance = Vector3.Distance(transform.position, Camera.main.transform.position);
        if (distance <= distanceThreshold)
        {
            // Show the text if the player is in range
            isInRange = true;
            canvas.enabled = true;
            text.enabled = true;

            // Play the sound if it hasn't already played
            if (!hasPlayedSound)
            {
                audioSource.PlayOneShot(sound);
                hasPlayedSound = true;
            }
        }
        else if (isInRange)
        {
            // Hide the text if the player is no longer in range
            isInRange = false;
            canvas.enabled = false;
            text.enabled = false;
            hasPlayedSound = false;
        }
    }
}
