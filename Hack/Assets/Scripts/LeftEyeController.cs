using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LeftEyeController : MonoBehaviour
{
    public float minFOV = -70f;
    public float maxFOV = 70f;
    public float sensitivity = 2f;

    void Update()
    {
        float currentFOV = GetComponent<Camera>().fieldOfView;
        float deltaFOV = -Input.GetAxis("Horizontal") * sensitivity;
        float newFOV = Mathf.Clamp(currentFOV + deltaFOV, minFOV, maxFOV);
        GetComponent<Camera>().fieldOfView = newFOV;
    }
}