using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class StartButton : MonoBehaviour
{
    public void StartGame()
    {
        Debug.Log("Loading game scene...");
        SceneManager.LoadScene("SampleScene.unity");
    }
}
