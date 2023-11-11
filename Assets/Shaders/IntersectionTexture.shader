Shader "Custom/Intersection"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _IntersectionColor("Intersection Color", Color) = (0, 0, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }
        
        Pass
        {
            Name "IntersectionUnlit"
            Tags { "LightMode"="SRPDefaultUnlit" }
            
            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            
            TEXTURE2D(_Color);              SAMPLER(sampler_Color);
            TEXTURE2D(_IntersectionColor);  SAMPLER(sampler_IntersectionColor);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _Color_ST;
            float4 _IntersectionColor_ST;
            CBUFFER_END
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 PositionWS : TEXCOORD1;
                float2 uv : TEXCOORD0;
            };
            
            Varyings vert (Attributes input)
            {
                Varyings output;
                
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.PositionWS = TransformObjectToWorld(input.positionOS.xyz);
                
                output.uv = input.uv * (_Color_ST.xy + _IntersectionColor_ST.xy)
                + (_Color_ST.zw + _IntersectionColor_ST.zw);
                
                return output;
            }
            float4 frag (Varyings input) : SV_TARGET
            {
                const float2 screenUV = GetNormalizedScreenSpaceUV(input.positionHCS);
                const float SceneDepth = SampleSceneDepth(screenUV);
                
                const float depthTexture = LinearEyeDepth(SceneDepth, _ZBufferParams);
                const float depthObject = LinearEyeDepth(input.PositionWS, UNITY_MATRIX_V);
                
                const float lerpValue = pow(1 - saturate(depthTexture - depthObject), 15);
                
                const float4 colObject = SAMPLE_TEXTURE2D(_Color, sampler_Color, input.uv);
                const float4 colIntersection = SAMPLE_TEXTURE2D(_IntersectionColor, sampler_IntersectionColor, input.uv);
                
                return lerp(colObject, colIntersection, lerpValue);
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
