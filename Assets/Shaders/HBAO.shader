Shader "karonator/HBAO" {
    SubShader {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform sampler2D _Tex0; // color
            uniform sampler2D _Tex1; // normal
            uniform sampler2D _CameraDepthTexture;
            
            uniform float4x4 _clipToWorld;
            uniform float4x4 _worldToView;

            float3 screenToWorld(float2 uv) {
                float depth = tex2D(_CameraDepthTexture, uv).x;
                float4 clipSpacePosition = float4(uv * 2.0 - 1.0, depth, 1.0);
                float4 worldPosition = mul(_clipToWorld, clipSpacePosition);
                return worldPosition.xyz /worldPosition.w;
            }

            float3 worldToView(float3 p) {
                float4 result = mul(_worldToView, float4(p, 1.0));
                return result.xyz /result.w;
            }

            float4 frag(v2f_img input): COLOR {
                const float PI = 3.14159265;

                float2 uv = input.uv;

                float3 pointVS = worldToView(screenToWorld(uv));

                float3 albedo = tex2D(_Tex0, uv).xyz;
                float4 raw_normal = tex2D(_Tex1, uv);
                float3 normal = normalize(2 * (raw_normal.xyz - 0.5));
                float3 normalVS = normalize(mul((float3x3)_worldToView, normal).xyz);

                const float radiusSS = 64.0 / 512.0;
                const int directionsCount = 64;
                const int stepsCount = 32;

                float theta = 2.0 * PI / float(directionsCount);
                float2x2 deltaRotationMatrix = float2x2(
                    cos(theta), -sin(theta),
                    sin(theta),  cos(theta)
                );
                float2 deltaUV = float2(radiusSS / (stepsCount + 1.0), 0.0);

                float occlusion = 0.0;

                for (int i = 0; i < directionsCount; i++) {
                    float horizonAngle = 0.04;
                    deltaUV = mul(deltaRotationMatrix, deltaUV);

                    for (int j = 1; j <= stepsCount; j++) {
                        float2 sampleUV = uv + j * deltaUV;
                        float3 sampleVS = worldToView(screenToWorld(sampleUV));
                        float3 sampleDirVS = sampleVS - pointVS;

                        float angle = (PI / 2.0) - acos(dot(normalVS, normalize(sampleDirVS)));  
                        if (angle > horizonAngle) {
                            float value = sin(angle) - sin(horizonAngle);
                            float attenuation = clamp(1.0 - pow(length(sampleDirVS) / 2.0, 2.0), 0.0, 1.0);
                            occlusion += value * attenuation;
                            horizonAngle = angle;
                        }

                    }
                }

                occlusion = 1.0 - occlusion / directionsCount;
                occlusion = clamp(pow(occlusion, 2.7), 0.0, 1.0);

                float3 outColor = float3(occlusion, occlusion, occlusion);
                outColor = pow(outColor, 1 / 2.2); // gamma correction
                return float4(outColor * albedo, 1.0);
            }
            ENDCG
        }
    }
}