Shader "Learn/ComplexLight/ForwardRendering"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _Valve ("Valve", Range(0, 1)) = 0.5
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma multi_compile_fwdbase   // 确保光照衰减等变量正确赋值
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            fixed _Valve;
            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                // _LightColor0 已经是颜色和强度相乘的结果
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * (dot(worldNormal, worldLightDir) * _Valve + 1 - _Valve);

                fixed3 halfDir = normalize(worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                fixed atten = 1;
                return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }

        pass
        {
            Tags { "LightMode"="ForwardAdd" }
            Blend One One   // 使可以在帧缓存中与之前的的光照结果进行叠加

            CGPROGRAM
            #pragma multi_compile_fwdadd
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            fixed _Valve;
            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                #ifdef USING_DIRECTIONAL_LIGHT
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                #else
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                #endif
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                // _LightColor0 已经是颜色和强度相乘的结果
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * (dot(worldNormal, worldLightDir) * _Valve + 1 - _Valve);

                fixed3 halfDir = normalize(worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                fixed atten = 1;
                return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }
    }
}
