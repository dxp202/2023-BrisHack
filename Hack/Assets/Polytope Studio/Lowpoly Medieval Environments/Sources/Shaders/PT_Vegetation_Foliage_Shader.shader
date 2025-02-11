// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Polytope Studio/PT_Vegetation_Foliage_Shader"
{
	Properties
	{
		[NoScaleOffset]_BaseTexture("Base Texture", 2D) = "white" {}
		[Toggle]_CUSTOMCOLORSTINTING("CUSTOM COLORS  TINTING", Float) = 0
		[HDR]_TopColor("Top Color", Color) = (0,0.2178235,1,1)
		[HDR]_GroundColor("Ground Color", Color) = (1,0,0,1)
		[HDR]_Gradient("Gradient", Range( 0 , 1)) = 1
		_GradientPower("Gradient Power", Range( 0 , 10)) = 5
		_LeavesThickness("Leaves Thickness", Range( 0.1 , 0.95)) = 0.5
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[Toggle(_TRANSLUCENCYONOFF_ON)] _TRANSLUCENCYONOFF("TRANSLUCENCY ON/OFF", Float) = 1
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		[Toggle(_CUSTOMWIND1_ON)] _CUSTOMWIND1("CUSTOM WIND", Float) = 1
		_WindMovement1("Wind Movement", Range( 0 , 10)) = 0.5
		_WindDensity1("Wind Density", Range( 0 , 5)) = 0.2
		_WindStrength1("Wind Strength", Range( 0 , 1)) = 0.3
		[HideInInspector]_MaskClipValue("Mask Clip Value", Range( 0 , 1)) = 0.5
		[Toggle(_SNOWONOFF_ON)] _SNOWONOFF("SNOW ON/OFF", Float) = 0
		_SnowGradient("Snow Gradient", Range( 0 , 1)) = 0.83
		_SnowCoverage("Snow Coverage", Range( 0 , 1)) = 0.45
		_SnowAmount("Snow Amount", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "DisableBatching" = "True" }
		Cull Off
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.5
		#pragma multi_compile_instancing
		#pragma shader_feature _CUSTOMWIND1_ON
		#pragma shader_feature_local _SNOWONOFF_ON
		#pragma shader_feature_local _TRANSLUCENCYONOFF_ON
		#pragma multi_compile __ LOD_FADE_CROSSFADE
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
		};

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Translucency;
		};

		uniform float _WindMovement1;
		uniform float _WindDensity1;
		uniform float _WindStrength1;
		uniform float _CUSTOMCOLORSTINTING;
		uniform sampler2D _BaseTexture;
		uniform float4 _GroundColor;
		uniform float4 _TopColor;
		uniform float _Gradient;
		uniform float _GradientPower;
		uniform float _SnowAmount;
		uniform float _SnowGradient;
		uniform float _SnowCoverage;
		uniform float _Smoothness;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform float _LeavesThickness;
		uniform float _MaskClipValue;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_vertex4Pos = v.vertex;
			float simplePerlin2D789 = snoise( (ase_vertex4Pos*1.0 + ( _Time.y * _WindMovement1 )).xy*_WindDensity1 );
			simplePerlin2D789 = simplePerlin2D789*0.5 + 0.5;
			float4 appendResult797 = (float4(( ( ( ( simplePerlin2D789 - 0.5 ) / 10.0 ) * _WindStrength1 ) + ase_vertex4Pos.x ) , ase_vertex4Pos.y , ase_vertex4Pos.z , 1.0));
			float4 lerpResult799 = lerp( ase_vertex4Pos , appendResult797 , ( ase_vertex4Pos.y * 2.0 ));
			float4 transform800 = mul(unity_WorldToObject,float4( _WorldSpaceCameraPos , 0.0 ));
			float4 temp_cast_2 = (transform800.w).xxxx;
			#ifdef _CUSTOMWIND1_ON
				float4 staticSwitch802 = ( lerpResult799 - temp_cast_2 );
			#else
				float4 staticSwitch802 = ase_vertex4Pos;
			#endif
			float4 LOCALWIND803 = staticSwitch802;
			v.vertex.xyz = LOCALWIND803.xyz;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			#if !defined(DIRECTIONAL)
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + c;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float2 uv_BaseTexture2 = i.uv_texcoord;
			float4 tex2DNode2 = tex2D( _BaseTexture, uv_BaseTexture2 );
			float grayscale180 = (tex2DNode2.rgb.r + tex2DNode2.rgb.g + tex2DNode2.rgb.b) / 3;
			float4 temp_cast_1 = (grayscale180).xxxx;
			float4 ase_vertex4Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float clampResult738 = clamp( pow( ( (0.5 + (ase_vertex4Pos.y - 0.0) * (2.0 - 0.5) / (1.0 - 0.0)) * _Gradient ) , _GradientPower ) , -1.0 , 1.0 );
			float4 lerpResult557 = lerp( _GroundColor , _TopColor , clampResult738);
			float4 GRADIENT558 = lerpResult557;
			float4 blendOpSrc18 = CalculateContrast(0.1,temp_cast_1);
			float4 blendOpDest18 = GRADIENT558;
			float4 lerpBlendMode18 = lerp(blendOpDest18,( blendOpSrc18 * blendOpDest18 ),0.0);
			float4 COLOR502 = (( _CUSTOMCOLORSTINTING )?( ( saturate( lerpBlendMode18 )) ):( tex2DNode2 ));
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float4 color443 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float fresnelNdotV454 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode454 = ( 0.11 + 1.0 * pow( 1.0 - fresnelNdotV454, color443.r ) );
			float smoothstepResult531 = smoothstep( 0.0 , _SnowGradient , ( ( i.uv_texcoord.y * 0.65 ) + (-1.0 + (_SnowCoverage - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ));
			float SNOW489 = ( ( (0.0 + (_SnowAmount - 0.0) * (10.0 - 0.0) / (1.0 - 0.0)) * fresnelNode454 ) * smoothstepResult531 );
			#ifdef _SNOWONOFF_ON
				float4 staticSwitch372 = ( SNOW489 + COLOR502 );
			#else
				float4 staticSwitch372 = COLOR502;
			#endif
			o.Albedo = staticSwitch372.rgb;
			o.Smoothness = _Smoothness;
			#ifdef _TRANSLUCENCYONOFF_ON
				float4 staticSwitch493 = ( COLOR502 * 1.0 );
			#else
				float4 staticSwitch493 = float4( 0,0,0,0 );
			#endif
			float4 TRANSLUCENCY497 = staticSwitch493;
			o.Translucency = TRANSLUCENCY497.rgb;
			o.Alpha = 1;
			float GENERALALPHA505 = tex2DNode2.a;
			float ALPHACUTOFF496 = ( 1.0 - step( GENERALALPHA505 , ( 1.0 - _LeavesThickness ) ) );
			clip( ALPHACUTOFF496 - _MaskClipValue );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustom keepalpha fullforwardshadows exclude_path:deferred dithercrossfade vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.5
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputStandardCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=18912
17;380;1641;689;4481.086;-969.3186;1.490583;True;False
Node;AmplifyShaderEditor.CommentaryNode;544;-1538.46,-972.0139;Inherit;False;1541.214;770.4899;GRADIENT;11;557;738;556;553;547;546;744;747;746;739;558;GRADIENT;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;739;-1523.9,-552.8172;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;744;-1326.038,-514.4321;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.5;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;781;-4118.427,1012.887;Inherit;False;4003.923;655.1426;WIND;22;803;802;801;800;799;798;797;796;795;794;793;792;791;790;789;788;787;786;785;784;783;782;VERTEX WIND;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;546;-1475.624,-318.8477;Float;False;Property;_Gradient;Gradient;4;1;[HDR];Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;547;-1110.976,-512.754;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;746;-1187.027,-304.8759;Inherit;False;Property;_GradientPower;Gradient Power;5;0;Create;True;0;0;0;False;0;False;5;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;782;-4022.831,1342.083;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;783;-4093.25,1471.207;Inherit;False;Property;_WindMovement1;Wind Movement;17;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;784;-3696.882,1482.751;Inherit;False;Property;_WindDensity1;Wind Density;18;0;Create;True;0;0;0;False;0;False;0.2;1.91;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;786;-3828.842,1345.022;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;747;-920.3145,-512.8779;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;39;-2704.9,-111.1786;Inherit;False;2726.816;529.2971;COLOR;9;505;502;336;18;352;728;180;2;127;COLOR;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;785;-3991.834,1077.031;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;738;-745.4936,-681.0336;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;556;-1398.07,-934.2432;Float;False;Property;_GroundColor;Ground Color;3;1;[HDR];Create;True;0;0;0;False;0;False;1,0,0,1;0.01743852,0.5754717,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;787;-3470.405,1402.138;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;788;-3671.405,1237.215;Inherit;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;553;-1400.975,-729.489;Float;False;Property;_TopColor;Top Color;2;1;[HDR];Create;True;0;0;0;False;0;False;0,0.2178235,1,1;0.05298166,0.3490566,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;127;-2684.817,-34.12083;Inherit;True;Property;_BaseTexture;Base Texture;0;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.NoiseGeneratorNode;789;-3387.566,1230.109;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;557;-602.1736,-865.377;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-2291.393,-5.608733;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;790;-3127.184,1228.701;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;558;-240.0452,-848.7395;Inherit;False;GRADIENT;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;363;-1660.093,1917.527;Inherit;False;1693.406;1367.284;Comment;15;489;467;458;531;532;452;454;535;446;455;443;445;528;529;527;SNOW;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCGrayscale;180;-1770.382,24.23656;Inherit;True;2;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;791;-3066.988,1461.405;Inherit;False;Property;_WindStrength1;Wind Strength;19;0;Create;True;0;0;0;False;0;False;0.3;0.203;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;527;-1439.001,2972.903;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;792;-2838.291,1295.284;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;728;-1581.035,24.87127;Inherit;True;2;1;COLOR;0,0,0,0;False;0;FLOAT;0.1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;529;-1476.111,3139.16;Inherit;False;Constant;_Float0;Float 0;22;0;Create;True;0;0;0;False;0;False;0.65;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;445;-1208.042,2744.531;Inherit;True;Property;_SnowCoverage;Snow Coverage;23;0;Create;True;0;0;0;False;0;False;0.45;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;352;-1383.648,232.0044;Inherit;False;558;GRADIENT;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;793;-2684.418,1230.987;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;455;-874.9898,2746.986;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;528;-1139.862,3021.589;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;446;-1546.916,2009.55;Inherit;False;Property;_SnowAmount;Snow Amount;24;0;Create;True;0;0;0;False;0;False;1;0.82;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;443;-1619.278,2272.284;Inherit;False;Constant;_Color1;Color 1;30;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;18;-1189.932,-13.21011;Inherit;True;Multiply;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;532;-895.5118,2301.897;Inherit;False;Property;_SnowGradient;Snow Gradient;22;0;Create;True;0;0;0;False;0;False;0.83;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;336;-863.1887,-66.5021;Inherit;False;Property;_CUSTOMCOLORSTINTING;CUSTOM COLORS  TINTING;1;0;Create;True;0;0;0;False;0;False;0;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;795;-2077.414,1436.959;Inherit;False;Constant;_Float5;Float 4;7;0;Create;True;0;0;0;False;0;False;2;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;535;-628.894,2708.991;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;741;-1203.495,556.3467;Inherit;False;1198.91;343.9196;Comment;6;106;128;107;116;740;496;ALPHA;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;452;-1158.428,2021.16;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;794;-2445.982,1093.363;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;454;-1385.883,2183.992;Inherit;False;Standard;WorldNormal;ViewDir;True;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0.11;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;502;-200.9671,-35.26162;Inherit;False;COLOR;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-1153.495,673.434;Inherit;False;Property;_LeavesThickness;Leaves Thickness;6;0;Create;True;0;0;0;False;0;False;0.5;0.346;0.1;0.95;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;458;-903.7538,2134.55;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;796;-1621.611,1442.376;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;797;-2156.542,1113.304;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;505;-1962.379,200.54;Inherit;False;GENERALALPHA;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;365;-1053.508,3402.887;Inherit;False;1092.364;358.1904;Comment;5;497;493;486;491;481;TRANSLUCENCY;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;798;-1917.636,1133.689;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;531;-533.8249,2342.536;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;799;-1532.817,1026.658;Inherit;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;800;-1339.246,1426.699;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;740;-847.2863,606.3467;Inherit;False;505;GENERALALPHA;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;481;-988.546,3440.888;Inherit;False;502;COLOR;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;467;-402.3637,2148.709;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;486;-960.4905,3525.454;Inherit;False;Constant;_Float6;Float 6;15;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;128;-860.5824,695.5936;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;801;-1125.63,1074.01;Inherit;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StepOpNode;107;-634.9,638.9446;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;489;-226.8627,2133.406;Inherit;True;SNOW;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;491;-703.1473,3498.23;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;116;-414.9932,646.2662;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;802;-674.6061,1107.678;Inherit;False;Property;_CUSTOMWIND1;CUSTOM WIND;16;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;493;-538.4254,3469.279;Inherit;True;Property;_TRANSLUCENCYONOFF;TRANSLUCENCY ON/OFF;8;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;367;1311.255,298.9597;Inherit;True;502;COLOR;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;366;1350.336,516.4232;Inherit;False;489;SNOW;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;803;-362.0561,1126.913;Inherit;False;LOCALWIND;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;496;-229.5852,647.0934;Inherit;False;ALPHACUTOFF;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;368;1567.299,408.4161;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;497;-230.6066,3468.484;Inherit;False;TRANSLUCENCY;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;506;1738.329,541.7998;Inherit;False;496;ALPHACUTOFF;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;507;1729.641,466.1032;Inherit;False;497;TRANSLUCENCY;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;372;1718.154,296.2032;Inherit;False;Property;_SNOWONOFF;SNOW ON/OFF;21;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;742;1770.503,401.9955;Inherit;False;Property;_Smoothness;Smoothness;7;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;2085.109,83.74197;Inherit;False;Property;_MaskClipValue;Mask Clip Value;20;1;[HideInInspector];Fetch;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;354;1386.197,625.6137;Inherit;False;803;LOCALWIND;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;62;2050.875,301.853;Float;False;True;-1;3;;0;0;Standard;Polytope Studio/PT_Vegetation_Foliage_Shader;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;9;-1;-1;0;False;0;0;False;-1;-1;0;True;130;1;Pragma;multi_compile __ LOD_FADE_CROSSFADE;False;;Custom;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;744;0;739;2
WireConnection;547;0;744;0
WireConnection;547;1;546;0
WireConnection;786;0;782;0
WireConnection;786;1;783;0
WireConnection;747;0;547;0
WireConnection;747;1;746;0
WireConnection;738;0;747;0
WireConnection;787;0;784;0
WireConnection;788;0;785;0
WireConnection;788;2;786;0
WireConnection;789;0;788;0
WireConnection;789;1;787;0
WireConnection;557;0;556;0
WireConnection;557;1;553;0
WireConnection;557;2;738;0
WireConnection;2;0;127;0
WireConnection;790;0;789;0
WireConnection;558;0;557;0
WireConnection;180;0;2;0
WireConnection;792;0;790;0
WireConnection;728;1;180;0
WireConnection;793;0;792;0
WireConnection;793;1;791;0
WireConnection;455;0;445;0
WireConnection;528;0;527;2
WireConnection;528;1;529;0
WireConnection;18;0;728;0
WireConnection;18;1;352;0
WireConnection;336;0;2;0
WireConnection;336;1;18;0
WireConnection;535;0;528;0
WireConnection;535;1;455;0
WireConnection;452;0;446;0
WireConnection;794;0;793;0
WireConnection;794;1;785;1
WireConnection;454;3;443;0
WireConnection;502;0;336;0
WireConnection;458;0;452;0
WireConnection;458;1;454;0
WireConnection;797;0;794;0
WireConnection;797;1;785;2
WireConnection;797;2;785;3
WireConnection;505;0;2;4
WireConnection;798;0;785;2
WireConnection;798;1;795;0
WireConnection;531;0;535;0
WireConnection;531;2;532;0
WireConnection;799;0;785;0
WireConnection;799;1;797;0
WireConnection;799;2;798;0
WireConnection;800;0;796;0
WireConnection;467;0;458;0
WireConnection;467;1;531;0
WireConnection;128;0;106;0
WireConnection;801;0;799;0
WireConnection;801;1;800;4
WireConnection;107;0;740;0
WireConnection;107;1;128;0
WireConnection;489;0;467;0
WireConnection;491;0;481;0
WireConnection;491;1;486;0
WireConnection;116;0;107;0
WireConnection;802;1;785;0
WireConnection;802;0;801;0
WireConnection;493;0;491;0
WireConnection;803;0;802;0
WireConnection;496;0;116;0
WireConnection;368;0;366;0
WireConnection;368;1;367;0
WireConnection;497;0;493;0
WireConnection;372;1;367;0
WireConnection;372;0;368;0
WireConnection;62;0;372;0
WireConnection;62;4;742;0
WireConnection;62;7;507;0
WireConnection;62;10;506;0
WireConnection;62;11;354;0
ASEEND*/
//CHKSM=CB49D6D2E7C358658F57212D0508DF975FE4FDBA