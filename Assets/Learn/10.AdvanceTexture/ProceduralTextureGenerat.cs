using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProceduralTextureGenerat : MonoBehaviour
{
    public Material material;
    private Texture2D m_generatedTexture;
    #region Material Proterties
    [SerializeField, SetProperty("TextureWidth")]
    private int m_textureWidth = 512;
    public int TextureWidth
    {
        get { return m_textureWidth; }
        set
        {
            m_textureWidth = value;
            UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("BackgroundColor")]
    private Color m_backgroundColor = Color.white;
    public Color BackgroundColor
    {
        get { return m_backgroundColor; }
        set
        {
            m_backgroundColor = value;
            UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("CircleColor")]
    private Color m_circleColor = Color.white;
    public Color CircleColor
    {
        get { return m_circleColor; }
        set
        {
            m_circleColor = value;
            UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("BlurFactor")]
    private float m_blurFactor = 2.0f;
    public float BlurFactor
    {
        get { return m_blurFactor; }
        set
        {
            m_blurFactor = value;
            UpdateMaterial();
        }
    }
    #endregion

    // Start is called before the first frame update
    void Start()
    {
        if (material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if (renderer == null)
            {
                Debug.LogWarning("Cannot find a renderer.");
                return;
            }
            material = renderer.sharedMaterial;
        }
        UpdateMaterial();
    }

    // Update is called once per frame
    void Update()
    {

    }


    private void UpdateMaterial()
    {
        if (material == null) return;
        m_generatedTexture = GenerateProceduralTextrue();
        material.SetTexture("_MainTex", m_generatedTexture);
    }

    private Texture2D GenerateProceduralTextrue()
    {
        Texture2D proceduralTexture = new Texture2D(TextureWidth, TextureWidth);
        float circleInterval = TextureWidth / 4.0f;
        float radius = TextureWidth / 10.0f;
        float edgeBlur = 1.0f / BlurFactor;
        for (int w = 0; w < TextureWidth; w++)
        {
            for (int h = 0; h < TextureWidth; h++)
            {
                Color pixel = BackgroundColor;
                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;

                        Color color = MixColor(CircleColor, new Color(pixel.r, pixel.g, pixel.b, 0), Mathf.SmoothStep(0, 1, dist * edgeBlur));
                        pixel = MixColor(pixel, color, color.a);
                    }
                }
                proceduralTexture.SetPixel(w, h, pixel);
            }
        }
        proceduralTexture.Apply();

        return proceduralTexture;
    }

    private Color MixColor(Color circleColor, Color color, float v)
    {
        return circleColor * (1 - v) + color * v;
    }
}
