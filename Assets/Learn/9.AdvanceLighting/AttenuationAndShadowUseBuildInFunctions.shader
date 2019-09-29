Shader "Learn/9.AdvanceLighting/AttenuationAndShadowUseBuildInFunctions"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)  
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss",Range(8, 256)) = 20
    }
    SubShader
    {
        // base pass 处理的逐像素光一定是平行光  通过_WorldSpaceLightPos0获取位置，_LightColor0得到颜色和强度
        Pass
        {
            Tags{ "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma multi_compile_fwdbase   // 使用光照衰减等变量

            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            
            #include "AutoLight.cginc" //计算阴影
            #include "Lighting.cginc"  //使用 _LightColor0 场景灯光

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                SHADOW_COORDS(2)  //阴影坐标
            };

            v2f vert (a2v v)
            {
                v2f o;  
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o);    //计算阴影纹理坐标
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                // fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);
                // fixed atten = 1.0; // 平行光衰减

                // fixed shadow = SHADOW_ATTENUATION(i);
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos.xyz); // 同时处理衰减和阴影
                return fixed4(ambient + (diffuse + specular) * atten, 1) ;
            }
            ENDCG
        }

        // Additional Pass 
        pass{
            Tags { "LightMode"="ForwardAdd" }
            Blend One One  // 使计算结果与之前的光照结果叠加
            CGPROGRAM
            // #pragma multi_compile_fwdadd    // 保证访问到正确的光照变量
            #pragma multi_compile_fwdadd_fullshadows    //为逐像素光源计算阴影

            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"  // 使用 unity_WorldToLight
            #include "Lighting.cginc"  //使用 _LightColor0 场景灯光 获取颜色和强度
 
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                SHADOW_COORDS(2)  //阴影坐标
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o);    //计算阴影纹理坐标
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                // fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);
                // fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                // fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

                // #ifdef USING_DIRECTIONAL_LIGHT
                // fixed atten = 1.0; // 衰减
                // #else
                // float3 lightCoord = mul(unity_WorldToLight, i.worldPos).xyz;
                // // 通过纹理查找表获得光照衰减
                // fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                // // atten = 1.0 / length(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);//手动计算
                // #endif
                // fixed shadow = SHADOW_ATTENUATION(i);


                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos.xyz); // 同时处理衰减和阴影
                return fixed4((diffuse + specular) * atten, 1);
            }

            ENDCG
        }
    }
    Fallback "Specular"
}

