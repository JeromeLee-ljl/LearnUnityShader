using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ReflectionCube : MonoBehaviour
{
    public Transform position;
    public Cubemap cubemap;
    private Camera camera;
    // Start is called before the first frame update
    void Start()
    {
        camera = new GameObject("CubemapCamera").AddComponent<Camera>();
        camera.transform.parent = transform;
    }

    void RenderCubeMap(){
        camera.transform.position = position.position;
        camera.RenderToCubemap(cubemap);
    }

    // Update is called once per frame
    void Update()
    {
        RenderCubeMap();
    }
}
