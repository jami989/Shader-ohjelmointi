Shader "Custom/TextureSample1"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _TaskTex("Main Texture", 2D) = "white" {}
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
            TEXTURE2D(_TaskTex);
            SAMPLER(sampler_TaskTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            CBUFFER_END
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            Varyings vert (Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                return output;
            }
            float4 frag (Varyings input) : SV_TARGET
            {
                const float4 color1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                const float4 color2 = SAMPLE_TEXTURE2D(_TaskTex, sampler_TaskTex, input.uv);
                const float4 finalColor = lerp(color1, color2, (sin(input.uv.x * 5) + 1) / 2);
                
                return finalColor;
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
