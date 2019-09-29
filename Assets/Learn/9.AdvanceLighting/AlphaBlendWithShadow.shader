Shader "Learn/9.AdvanceLighting/AlphaBlendWithShadow"
{
    Properties
    {
        _Color ("Main Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaScale ("Alpha Scale", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { 
        "Queue"="Transparent"
        "IgnoreProjector"="True"
        "RenderType"="Transparent"  // 说明subshader使用了透明度混合
        }

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            ZWrite Off                      // 关闭深度写入
            Blend SrcAlpha OneMinusSrcAlpha // 混合类型  8.6.2

            CGPROGRAM
            #pragma multi_compile_fwdbase   // 使用光照衰减等变量
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;
            
            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
                float2 uv : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed4 texColor = tex2D(_MainTex, i.uv);
                fixed3 albedo = texColor.rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo *  max(0, dot(worldNormal, worldLightDir));
                 UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);  // 同时处理衰减和阴影  
                return fixed4(ambient + diffuse * atten, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
    // FallBack "Transparent/VertexLit"
    Fallback "VertexLit"
}
