
Shader "Learn/Simple3Shader"{
    Properties{
        _Diffuse("DiffuseColor", Color) = (1, 1, 1, 1)  
        _ValveIndex("ValveIndex", Range(0, 1)) = 0.5
        _HighLightColor("HightLightColor", Color) = (1, 1, 1, 1)
        _HighLightness("HightLightness",Range(0, 256)) = 8
    }

    SubShader{
        pass{
            // Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"  // 使用 _LightColor0 场景灯光
            fixed4 _Diffuse;  // float 32bit, half 16bit, fixed 11bit, color[0,1]
            fixed _ValveIndex;
            fixed3 _HighLightColor;
            half _HighLightness;

            struct a2v{
                float4 vertex: POSITION; // 局部坐标系
                float3 normal: NORMAL;  // 局部坐标系
            };
            struct v2f{
                float4 pos: SV_POSITION; //裁剪坐标系中的position SV_POSITION(POSITION) 
                float3 worldPos: TEXCOORD1; // 世界空间中的position
                float3 worldNomal: TEXCOORD0; // 世界空间中的法线 TEXCOORD0存储自定义的数据
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex);
                o.worldNomal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f IN) : SV_TARGET{  // SV_TARGET(COLOR)
                float3 lDir = normalize(_WorldSpaceLightPos0.xyz); //光源方向 只适用于平行光
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(IN.worldPos)); // 视线方向
                _Diffuse = fixed4(IN.pos.xy / _ScreenParams.xy, 0, 1);
                fixed3 diffuse = _LightColor0 * _Diffuse * max(0.0, dot(IN.worldNomal, lDir) * _ValveIndex + (1 - _ValveIndex)); // 漫反射光  
                fixed3 hightLight = _LightColor0 * _HighLightColor * pow(saturate(dot(IN.worldNomal, normalize(viewDir + lDir))), _HighLightness); //saturate取{0，1]范围的值
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;  // 环境光
                return fixed4(ambient + diffuse + hightLight, 1.0);
            }

            // fixed4 frag(float4 sp: VPOS) : SV_TARGET{
            //     return fixed4(sp.xy / _ScreenParams.xy, 0, 1);
            // }

            ENDCG                  
        }
    }

    Fallback "Diffuse"
}