Shader "Unlit/NewUnlitShader"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                fixed3 tangent : TANGENT;
                fixed3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed3 tangent : TEXCOORD0;
                fixed3 normal : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.tangent = mul((float3x3)unity_ObjectToWorld, v.tangent.xyz);
                o.normal = mul(unity_ObjectToWorld, v.normal);
                // o.normal = mul(v.normal, unity_WorldToObject);
                // o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed color = dot(i.tangent, i.normal);
                return fixed4(color, color, color, 1);
                // return fixed4(0.5,0.5,0.5,1)*fixed4(0.5,0.5,0.5,1);
                // return fixed4(0.25,0.25,0.25,1);
            }
            ENDCG
        }
    }
}
