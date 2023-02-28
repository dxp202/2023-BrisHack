﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    [SerializeField] private CharacterController controller;
    [SerializeField] private float speed = 5;
    [SerializeField] private float gravity = -9.18f;
    [SerializeField] private float jumpHeight = 3f;
    [SerializeField] private Transform groundCheck;
    [SerializeField] private float groundDistance = 0.4f;
    [SerializeField] private LayerMask groundMask;
    [SerializeField] private AudioSource audioSource;
    [SerializeField] private AudioClip walkSound;

    private Transform _transform;
    private Vector3 velocity;
    private bool isGrounded;
    private bool isWalking;

    void Start()
    {
        _transform = transform;
        isWalking = false;
    }

    void Update()
    {
        isGrounded = controller.isGrounded;

        if (Mathf.Approximately(velocity.y, 0f) && isGrounded)
        {
            velocity.y = -2f;
        }

        if (Input.GetKey("left shift") && isGrounded)
        {
            speed = 5;
        }
        else
        {
            speed = 5;
        }

        float x = Input.GetAxis("Horizontal");
        float z = Input.GetAxis("Vertical");

        Vector3 move = _transform.right * x + _transform.forward * z;

        if (move.magnitude > 0 && isGrounded)
        {
            if (!isWalking)
            {
                isWalking = true;
                audioSource.PlayOneShot(walkSound);
            }
        }
        else
        {
            if (isWalking)
            {
                isWalking = false;
                audioSource.Stop();
            }
        }

        controller.Move(move * speed * Time.deltaTime);

        if (Input.GetButtonDown("Jump") && isGrounded)
        {
            velocity.y = Mathf.Sqrt(jumpHeight * -1f * gravity);
        }

        velocity.y += gravity * Time.deltaTime;

        controller.Move(velocity * Time.deltaTime);
    }
}
