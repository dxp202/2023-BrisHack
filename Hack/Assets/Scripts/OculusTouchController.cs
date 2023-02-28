using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;

public class OculusTouchController : MonoBehaviour
{
    public float speed = 1.0f;

    private InputDevice leftController;
    private InputDevice rightController;

    void Start()
    {
        // 获取左右手柄的输入设备
        var leftHandedDevices = new List<InputDevice>();
        var rightHandedDevices = new List<InputDevice>();
        InputDevices.GetDevicesWithCharacteristics(InputDeviceCharacteristics.Left | InputDeviceCharacteristics.Controller, leftHandedDevices);
        InputDevices.GetDevicesWithCharacteristics(InputDeviceCharacteristics.Right | InputDeviceCharacteristics.Controller, rightHandedDevices);
        leftController = leftHandedDevices[0];
        rightController = rightHandedDevices[0];
    }

    void Update()
    {
        // 获取左右手柄的输入状态
        bool leftPrimaryButtonPressed = false;
        bool rightPrimaryButtonPressed = false;
        leftController.TryGetFeatureValue(CommonUsages.primaryButton, out leftPrimaryButtonPressed);
        rightController.TryGetFeatureValue(CommonUsages.primaryButton, out rightPrimaryButtonPressed);

        // 根据手柄输入状态更新游戏对象的位置
        Vector3 direction = Vector3.zero;
        if (leftPrimaryButtonPressed)
        {
            direction += transform.forward;
        }
        if (rightPrimaryButtonPressed)
        {
            direction += transform.right;
        }
        transform.position += direction.normalized * speed * Time.deltaTime;
    }
}