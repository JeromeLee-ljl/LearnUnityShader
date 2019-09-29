Shader "Learn/7.BaseTexture/MaskTexture"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1
        _SpecularMask ("Specular Mask", 2D) = "white" {}
        _SpecularScale ("Specular Scale", Float) = 1
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8,256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST; // 为三个纹理使用同一个属性
            sampler2D _BumpMap;
            float _BumpScale;
            sampler2D _SpecularMask;
            float _SpecularScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                fixed3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

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

                fixed4 packedNormal = tex2D(_BumpMap, o.uv);
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
                fixed specularMask =tex2D(_SpecularMask, o.uv).r * _SpecularScale;
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, tangentNormal)), _Gloss) * specularMask;
                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
