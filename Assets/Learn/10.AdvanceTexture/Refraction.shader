Shader "Learn/10.AdvanceTexture/Refraction"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _RefractColor ("Refraction Color", Color) = (1, 1, 1, 1)
        _RefractAmout ("Refract Amount", Range(0, 1)) = 1       // 控制反射程度
        _RefractRatio ("Refraction Ratio", Range(0.1, 1)) = 0.5 
        _Cubemap ("Refraction Cubemap", Cube) = "_Skybox" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma multi_compile_fwdbase   // 使用光照衰减等变量
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            fixed3 _Color;
            fixed3 _RefractColor;
            fixed _RefractAmout;
            fixed _RefractRatio;
            samplerCUBE _Cubemap;
            

            struct a2v
            {
                float4 vertex : POSITION;
                fixed3 normal : NORMAL;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
                // fixed3 worldViewDir : TEXCOORD2;
                // fixed3 worldRefl : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_TARGET
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 worldRefr = refract(-worldViewDir, worldNormal, _RefractRatio);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));
                fixed3 refraction = texCUBE(_Cubemap, worldRefr).rgb * _RefractColor.rgb;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 color = ambient + lerp(diffuse, refraction, _RefractAmout) * atten;
                // fixed3 color = ambient + (diffuse*(1-_ReflectAmout) + reflection * _RefractAmout) * max(0.5, atten);
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
    Fallback "VertexLit"
}
