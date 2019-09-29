Shader "Learn/11.Animation/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1,1,1,1)
        _Magnitude ("Distortion Magnitude", Float) = 1  //波动幅度
        _Frequency ("Distortion Frequency", Float) = 1  //波动频率
        _InvWaveLength ("Distortion Inverse Wave Length", FLoat) = 10   //波长的倒数
        _Speed("Speed", Float) = 0.5
    }
    SubShader
    {
        Tags { "Quene"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"
            "DisableBatching" = "True"  // 是否对该SubShader使用批处理
        }

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float2 uv : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                float4 offset;
                offset.yzw = float3(0,0,0);

                // float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                offset.x = sin(-_Frequency * _Time.y + (v.vertex.x + v.vertex.y + v.vertex.z) * _InvWaveLength) * _Magnitude;

                o.vertex = UnityObjectToClipPos(v.vertex + offset);
                // o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex) + float2(0, _Time.y * _Speed);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex) ;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col * _Color;
            }
            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}
