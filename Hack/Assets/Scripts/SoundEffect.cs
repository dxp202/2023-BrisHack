using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundEffect : MonoBehaviour
{
    public AudioClip soundClip; // the sound clip to play
    public float soundDistance = 10f; // the distance at which the sound should start playing

    private AudioSource audioSource;
    private bool isPlaying;

    void Start()
    {
        audioSource = GetComponent<AudioSource>();
        isPlaying = false;
    }

    void Update()
    {
        // get the distance between the player and the object
        float distance = Vector3.Distance(transform.position, Camera.main.transform.position);

        // check if the player is close enough to the object to start playing the sound
        if (distance <= soundDistance && !isPlaying)
        {
            audioSource.clip = soundClip;
            audioSource.Play();
            isPlaying = true;
        }
        // check if the player is too far from the object to keep playing the sound
        else if (distance > soundDistance && isPlaying)
        {
            audioSource.Stop();
            isPlaying = false;
        }
    }
}