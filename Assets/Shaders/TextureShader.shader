Shader "CustomRenderTexture/TextureShader"
{
    Properties
    {
        _MainTex("Main texture", 2D) = "white" {}
        _SecTex("Second texture", 2D) = "white" {}
     }

     SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_MainTex);
            TEXTURE2D(_SecTex);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_SecTex);
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };
            
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Shininess;
            float4 _MainTex_ST;
            float4 _SecTex_ST;
            CBUFFER_END
            
            Varyings vert (Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.uv = input.uv; // uv * tiling + offset
                
                return output;
            }
            float4 frag (Varyings input) : SV_TARGET
            {
                const float4 Color1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                const float4 Color2 = SAMPLE_TEXTURE2D(_SecTex, sampler_SecTex, input.uv);

                const float4 FinalColor = lerp(Color1, Color2, (sin(input.uv.x * 5) + 1) / 2);
                
                return FinalColor;
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
