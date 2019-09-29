// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Learn/Simple2Shader"{
    Properties{
        _Diffuse("DiffuseColor",Color) = (1,1,1,1)  
    }

    SubShader{
        pass{
            // Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"  // 使用 _LightColor0 场景灯光
            fixed4 _Diffuse;  // float 32bit, half 16bit, fixed 11bit, color[0,1]

            struct a2v{
                // 都是局部坐标
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };
            struct v2f{
                float4 pos: SV_POSITION; // SV_POSITION(POSITION) SV_TARGET(COLOR)
                // fixed3 color: COLOR;
                float3 worldNomal: TEXCOORD0;//  TEXCOORD0存储自定义的数据
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex); // 从模型空间到裁剪空间
                o.worldNomal = normalize(UnityObjectToWorldNormal(v.normal));  // 世界空间的顶点法线 
                return o;
            }

            fixed4 frag(v2f IN) : SV_TARGET{
                float3 lDir = normalize(_WorldSpaceLightPos0.xyz); //只适用于平行光
                fixed3 diffuse = _LightColor0 * _Diffuse * saturate(dot(IN.worldNomal, lDir)); // 漫反射光  saturate取{0，1]范围的值
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;  // 环境光
                return fixed4(ambient + diffuse, 1.0);
            }

            ENDCG                  
        }
    }
}