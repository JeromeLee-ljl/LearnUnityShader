Shader "Learn/7.BaseTexture/Normal Map Tangent Space"{
    Properties{
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "write" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _Vavle ("Vavle", Range(0, 1)) = 0.5
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 256)) = 20
    }

    SubShader{
        pass{
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"


            fixed4 _Color;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _BumpMap;     // 法线贴图
            float4 _BumpMap_ST;
            float _BumpScale;

            float _Vavle;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float4 tangent: TANGENT;  // tangent.w 用来确定切线空间中副切线的方向性
                float4 texcood : TEXCOORD0; // float2 uv : TEXCOORD0;      // 原始纹理uv坐标  原点： unity中左下角 OpenGL左下角  DirectX左上角
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float4 uv: TEXCOORD0;       // xy 第一个纹理   zw 第二个纹理
                float3 lightDir: TEXCOORD1; // 切线空间
                float3 viewDir: TEXCOORD2; // 切线空间
            };


            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcood.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcood.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                // 副切线
                // float3 binormal = cross(normalize(v.tangent.xyz), v.normal) * v.tangent.w;
                // float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
                TANGENT_SPACE_ROTATION;

                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));

                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));

                return o;
            }

            fixed4 frag(v2f o) : SV_TARGET{
                fixed3 tangentLightDir = normalize(o.lightDir);
                fixed3 tangentViewDir = normalize(o.viewDir);

                fixed4 packedNormal = tex2D(_BumpMap, o.uv.zw);
                fixed3 tangentNormal;
                // tangentNormal.xy = (packedNormal.xy * 2 - 1);
                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, o.uv.xy).rgb * _Color;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

                // fixed3 diffuse = _LightColor0.rgb * albedo * (dot(tangentLightDir, tangentNormal)* _Vavle + 1- _Vavle);
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentLightDir, tangentNormal));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, tangentNormal)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1);
            }

            ENDCG
        }
    }
}