using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseLook : MonoBehaviour
{
    [SerializeField] private float mouseSensitivity = 100f;
    [SerializeField] private Transform playerBody;

    private Transform _transform;
    private float xRotation = 0f;

    void Start()
    {
        Cursor.visible = false;
        _transform = transform;
    }

    void Update()
    {
        float mouseX = Input.GetAxis("Mouse X") * mouseSensitivity * Time.deltaTime;
        float mouseY = Input.GetAxis("Mouse Y") * mouseSensitivity * Time.deltaTime;
        xRotation -= mouseY;
        xRotation = Mathf.Clamp(xRotation, -30f, 30f);
        _transform.localRotation = Quaternion.AngleAxis(xRotation, Vector3.right);
        playerBody.Rotate(0f, mouseX, 0f, Space.World);
    }
}

