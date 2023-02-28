using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RightEyeController : MonoBehaviour
{
    public float minConvergence = -0.5f;
    public float maxConvergence = 0.5f;
    public float sensitivity = 0.1f;

    void Update()
    {
        float currentConvergence = GetComponent<Camera>().stereoConvergence;
        float deltaConvergence = Input.GetAxis("Horizontal") * sensitivity;
        float newConvergence = Mathf.Clamp(currentConvergence + deltaConvergence, minConvergence, maxConvergence);
        GetComponent<Camera>().stereoConvergence = newConvergence;
    }
}