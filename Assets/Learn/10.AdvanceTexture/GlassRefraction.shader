Shader "Unlit/GlassRefraction"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _Cubemap ("Environment Cubemap", Cube) = "_Skybox" {}
        _Distortion ("Distortion", Range(0,100)) = 10   //折射时的扭曲程度
        _RefractAmount ("Refract Amount", Range(0, 1)) = 1  //折射程度
    }
    SubShader
    {
        Tags { 
            "Queue"="Transparent"   // 在其他不透明物体渲染后渲染
            "RenderType"="Opaque"   // 着色器替换时可以被正确渲染
        }
        GrabPass { "_RefractionTex" }   //抓取屏幕图像的pass  图像存入到 _RefractionTex
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed3 normal : NORMAL;
                fixed4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 grabPos : TEXCOORD1;
                float4 worldPos : TEXCOORD2;
                fixed3 worldNormal : TEXCOORD3;
                fixed3 worldTangent : TEXCOORD4;
                fixed3 worldBinormal : TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.pos); // 得到对应被抓取屏幕图像的采样坐标
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BumpMap);
                
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal  = UnityObjectToWorldNormal(v.normal);
                o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;

                // o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                // o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                // o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                return o;
            }

            samplerCUBE _Cubemap;
            float _Distortion;
            fixed _RefractAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;    // 纹素大小

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;// 切线空间中的偏移量
                bump  = normalize(mul(bump, fixed3x3(i.worldTangent, i.worldBinormal, i.worldNormal)));
                // float2 offset2 = bump.xy * 30 * _RefractionTex_TexelSize.xy;// 切线空间中的偏移量

                i.grabPos.xy = offset + i.grabPos.xy;
                // fixed3 refrCol = tex2Dproj(_RefractionTex, i.grabPos);   //
                fixed3 refrCol = tex2D(_RefractionTex, i.grabPos.xy/i.grabPos.w);


                fixed3 reflDir = reflect( -worldViewDir, bump);
                fixed4 texColor = tex2D( _MainTex, i.uv.xy);
                fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;

                fixed3 col = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
