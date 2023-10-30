Shader "Custom/ProximityDeform"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _PlayerPosition("Player Position", Vector) = (0, 0, 0, 0)
        _DistanceAttenuation("Distance Attenuation", Range(1, 10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 color;
            float3 _PlayerPosition;
            int _DistanceAttenuation;
            CBUFFER_END
            
            struct Attributes
            {
                float4 positionOS : POSITION;
            };
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };
            
            Varyings vert (Attributes input)
            {
                Varyings output;
                const float3 PositionWS = TransformObjectToWorld(input.positionOS.xyz);
                
                const float3 dir = PositionWS - _PlayerPosition;
                float distance = length(dir);
                distance = saturate(1 - distance / _DistanceAttenuation);

                output.positionHCS = TransformWorldToHClip(PositionWS + normalize(dir) * distance);
                
                return output;
            }
            float4 frag (Varyings input) : SV_TARGET
            {
                return color;
            }
            ENDHLSL
        }
    


        // Make grid not visible through shaders
        Pass
        {
            Name "Depth"
            Tags { "LightMode" = "DepthOnly" }
            
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask R
            
            HLSLPROGRAM
            
            #pragma vertex DepthVert
            #pragma fragment DepthFrag
             // PITÄÄ OLLA RELATIVE PATH TIEDOSTOON!!!
             #include "Common/DepthOnly.hlsl"
             ENDHLSL
        }

        Pass
        {
            Name "Normals"
            Tags { "LightMode" = "DepthNormalsOnly" }
            
            Cull Back
            ZTest LEqual
            ZWrite On
            
            HLSLPROGRAM
            
            #pragma vertex DepthNormalsVert
            #pragma fragment DepthNormalsFrag

            #include "Common/DepthNormalsOnly.hlsl"
            
            ENDHLSL
        }
    }
}
