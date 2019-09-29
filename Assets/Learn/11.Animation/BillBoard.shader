Shader "Learn/11.Animation/BillBoard"
{
    Properties{
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _VerticalBillboarding ("Vertical Restraints", Range(0, 1)) = 1
    }
    SubShader{
        Tags {
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent" 
            "DisableBatching" = "True"  //不使用批处理
        }

        Pass{
            Tags{"LightMode"="ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            struct a2v{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            }

            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            }

            sampler2D _MainTex;
            float4 _MainTex_ST:
            fixed4 _Color;
            fixed4 _VerticalBillboarding;

            v2f vert(a2v v){
                float3 center = float3(0, 0, 0);
                float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1)));
            }

            float4 frag(v2f i) : SV_TARGET{

            }
            ENDCG
        }
    }
}
