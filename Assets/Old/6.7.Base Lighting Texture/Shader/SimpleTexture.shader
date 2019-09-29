Shader "Learn/SimpleTexture"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)     // 主颜色
        _MainTex ("Texture", 2D) = "white" {}           // 纹理
        _HalfLambert ("Half Lambert", Range(0, 1)) = 0.5// 漫反射参数
        _Specular ("Specular", Color) = (1, 1, 1, 1)    // 镜面反射的颜色
        _Gloss ("Gloss", Range(8.0, 256)) = 20          // 光泽度
    }
    SubShader
    {
        // Tags { "RenderType"="Opaque" }
        // LOD 100
        Tags { "LightMode" = "ForwardBase" }    // 前向渲染

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            // #pragma multi_compile_fog

            #include "Lighting.cginc"    // 使用_LightColor0

            struct appdata
            {
                float4 vertex : POSITION;   // 模型空间顶点
                float3 normal : NORMAL;     // 模型空间法线
                float2 uv : TEXCOORD0;      // 原始纹理uv坐标  原点： unity中左下角 OpenGL左下角  DirectX左上角
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;    //裁剪空间坐标
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float2 uv : TEXCOORD2;  // 经过缩放平移后的uv坐标
                // UNITY_FOG_COORDS(1)
            };

            fixed4 _Color;
            sampler2D _MainTex;
            fixed _HalfLambert;
            float4 _MainTex_ST;     // S(Scale) T(Translation)  该纹理的缩放和平移值 ， xy存储缩放  zw存储平移
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                // o.vertex = mul(UNITY_MATRIX_MVP, v.vertex); // 效率低
                o.vertex = UnityObjectToClipPos(v.vertex);  

                o.worldNormal = normalize(mul(unity_ObjectToWorld, v.normal));
                // o.worldNormal = UnityObjectToWorldNormal(v.normal);

                // o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw; // 进行缩放平移
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                // UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);  // 因为插值处理过 所以要单位化
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                fixed3 albedo = tex2D(_MainTex, i.uv) * _Color.rgb; // tex2D对纹理进行采样
                
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;  

                // 漫反射
                // 1.兰伯特模型
                // fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir)); 
                // 2.半兰伯特模型
                fixed3 diffuse = _LightColor0.rgb * albedo * (dot(worldNormal, worldLightDir) * _HalfLambert + (1 - _HalfLambert));

                // 高光反射
                // 1.Phong模型
                // fixed3 reflectLightDir = reflect(-worldLightDir, worldNormal);
                // fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldViewDir, reflectLightDir)), _Gloss);
                // 2.Blinn-Phong模型
                fixed3 halfDir = normalize(worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, worldNormal)), _Gloss);

                // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }
}
