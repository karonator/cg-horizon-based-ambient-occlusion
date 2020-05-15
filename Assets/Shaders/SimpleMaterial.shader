Shader "karonator/SimpleMaterial"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset] _NormalMap("Normals", 2D) = "bump" {}
	}
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
			sampler2D _NormalMap;

			float4  _MainTex_ST;
            float3 _Color;

            struct vertex_data
            {
                float4 vertex: POSITION;
                float4 normal: NORMAL;
                float2 uv: TEXCOORD0;
            };

            struct fragment_in
            {
                float4 pos: POSITION;
				float2 uv : TEXCOORD1;
                float3 normal: TEXCOORD2;
            };

            struct fragment_out
            {
                float4 color : COLOR0;
                float4 normal : COLOR1;
            };

			fragment_in vert(vertex_data v)
            {
				fragment_in o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                
				o.normal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

			fragment_out frag(fragment_in i): COLOR
            {
				fragment_out o;
 
				float3 color = tex2D(_MainTex, i.uv * _MainTex_ST.xy);
				if (distance(color, 1.0) == 0) {
					color = _Color;
				}

				float3 N = normalize(i.normal);

                o.color = float4(color, 1.0);
                o.normal = float4(N * 0.5 + 0.5, 1.0);

                return o;
            }

            ENDCG
        }
    }

    Fallback "VertexLit"
}
