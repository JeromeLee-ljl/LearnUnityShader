Shader "Learn/7.BaseTexture/Normal Map World Space"{
    Properties{
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "write" {}
        _BumpMap ("Bump Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Range(-10, 10)) = 1.0
        _Valve ("Valve", Range(0,1)) = 0.5
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 256)) = 20
    }

    SubShader{
        // Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Opaque" }
        pass{
            Tags {"LightMode" = "ForwardBase"} 
            // ZWrite Off
            // Blend SrcAlpha OneMinusSrcAlpha // 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;

            fixed _Valve;
            fixed4 _Specular;
            float _Gloss;
            fixed _AlphaScale;

            struct a2v{
                float4 vertex : POSITION;
                fixed3 normal : NORMAL;
                fixed4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f{ 
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                fixed3 worldTangent : TEXCOORD2;
                fixed3 worldBinormal : TEXCOORD3;
                fixed3 worldNormal : TEXCOORD4;  //将世界空间下的顶点位置从存放在w分量中
            };

            v2f vert(a2v i){
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);

                o.uv.xy = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = TRANSFORM_TEX(i.uv, _BumpMap);

                o.worldPos = mul(unity_ObjectToWorld, i.vertex);

                o.worldNormal = UnityObjectToWorldNormal(i.normal);
                o.worldTangent = UnityObjectToWorldDir(i.tangent.xyz);
                o.worldBinormal =  cross(o.worldNormal, o.worldTangent) * i.tangent.w;

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 worldTangent = normalize(i.worldTangent);
                fixed3 worldBinormal = normalize(i.worldBinormal);
                fixed3 worldNormal = normalize(i.worldNormal);
                
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 worldBumpNormal;
                // worldBumpNormal.xy = packedNormal.xy * 2 - 1;
                worldBumpNormal.xy = UnpackNormal(packedNormal);
                worldBumpNormal.xy *= _BumpScale;
                worldBumpNormal.z = sqrt(1- dot(worldBumpNormal.xy, worldBumpNormal.xy));
                worldBumpNormal = mul(worldBumpNormal, float3x3(worldTangent, worldBinormal, worldNormal));


                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

                // 半兰伯特模型
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldBumpNormal, worldLightDir));
                
                // Blinn-Phong
                fixed3 halfDir = normalize(worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, worldBumpNormal)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}