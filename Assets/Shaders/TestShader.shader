Shader"Custom/TestShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue"="Geometry" }
        
        Pass{
            Name "OmaPass"
            Tags
        {
        "LightMode" = "UniversalForward"
    }
            
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_Position;
                float3 positionWS : TEXTCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            CBUFFER_END

            Varyings Vert(const Attributes input)
            {
            Varyings output;

            output.positionHCS = mul(UNITY_MATRIX_P ,mul(UNITY_MATRIX_V ,mul(UNITY_MATRIX_M, float4(input.positionOS, 1))));
            //output.positionHCS = TransformObjectToHClip(input.positionOS);
            //output.positionWS = TransformObjectToWorld(input.positionOS);
            ////output.positionWS = mul(UNITY_MATRIX_M, input.normalOS);

            return output;
            }

            half4 Frag(const Varyings input) : SV_Target{
                return _Color * clamp(input.positionWS.x, 0, 1);
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
