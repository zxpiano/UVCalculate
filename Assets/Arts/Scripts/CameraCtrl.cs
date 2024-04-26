using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraCtrl : MonoBehaviour
{
    private float _rotateSpeed;
    void Start()
    {
        _rotateSpeed = 2;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            float rotX = transform.localEulerAngles.y + Input.GetAxis("Mouse X") * _rotateSpeed;
            float rotY = transform.localEulerAngles.x + Input.GetAxis("Mouse Y") * _rotateSpeed;


            Quaternion rotationVertical = Quaternion.Euler(rotY, rotX, 0);
            //Quaternion rotationHorizon = Quaternion.Euler(0, rotX, 0);
            //transform.rotation = rotationHorizon;
            transform.rotation = rotationVertical;
        }

    }
}
