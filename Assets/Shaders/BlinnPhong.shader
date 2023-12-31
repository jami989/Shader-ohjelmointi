Shader "Custom/BlinnPhong"
{
    Properties
    {
        _Color("Color", Color) = (0.1, 0.4, 0, 1)
        _Shininess("Shininess", Range(1, 512)) = 1
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
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Shininess;
            CBUFFER_END
            
            Varyings vert (Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                return output;
            }
            float4 BlinnPhong(const Varyings input)
            {
                const Light mainLight = GetMainLight();
                
                const float3 ambientLight = 0.1 * mainLight.color;
                
                const float3 diffuseLight =  saturate(dot(input.normalWS, mainLight.direction)) * mainLight.color;
                
                const float3 viewDir = GetWorldSpaceNormalizeViewDir(input.positionWS);
                const float3 halfwayDir = normalize(mainLight.direction + viewDir);
                
                const float3 specularLight = pow(saturate(dot(input.normalWS, halfwayDir)), _Shininess) * mainLight.color;
                
                return float4((ambientLight + diffuseLight + specularLight * 10 /* <-- vaihtoehtoinen 10 */) * _Color.rgb, 1);
            }
            float4 frag (Varyings input) : SV_TARGET
            {
                return BlinnPhong(input);
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
