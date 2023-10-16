Shader"Custom/OffsetShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        
        [KeywordEnum(Object, World, View)]//!
        _Space("Space", Float) = 0 //!
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue"="Geometry" }
        
        Pass{
            Name "OmaPass"
            Tags {"LightMode" = "UniversalForward"}
            
            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment Frag

                #pragma shader_feature_local_vertex _SPACE_OBJECT _SPACE_WORLD _SPACE_VIEW //!

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

                    #if _SPACE_OBJECT
                    output.positionHCS = mul(UNITY_MATRIX_P ,mul(UNITY_MATRIX_V ,mul(UNITY_MATRIX_M, float4(input.positionOS + float3(0, 1, 0), 1))));
                    #elif _SPACE_WORLD
                    output.positionWS = TransformObjectToWorld(input.positionOS);
                    output.positionHCS = mul(UNITY_MATRIX_P ,mul(UNITY_MATRIX_V , float4(output.positionWS + float3(0, 1, 0), 1)));
                    #elif _SPACE_VIEW
                    const float3 positionVS = TransformWorldToView(TransformObjectToWorld(input.positionOS));
                    output.positionHCS = mul(UNITY_MATRIX_P ,float4(positionVS + float3(0, 1, 0), 1));
                    #endif
                    
    
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
