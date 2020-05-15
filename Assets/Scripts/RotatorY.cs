using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotatorY : MonoBehaviour
{
    [Range(0.0f, 100.0f)]
    public float rotationSpeed = 20f;
    public bool inverseRotation = false;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        int inverse = inverseRotation ? -1 : 1;
        transform.Rotate(Vector3.up * Time.deltaTime * rotationSpeed * inverse);
    }
}