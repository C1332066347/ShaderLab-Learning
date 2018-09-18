// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Demo"
{
	Properties
	{
		_Diffuse ("Diffuse", Color) = (0, 0, 0, 0)
	}
	SubShader
	{
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 color : COLOR;
			};

			v2f vert(a2v v) {
				v2f o;
				//从模型空间坐标转换为裁剪空间坐标
				o.pos = UnityObjectToClipPos(v.vertex);
				//UNITYZ_LIGHTMODEL_AMBIENT是一个全局变量，可以直接调用，得到环境光的颜色和强度信息
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				//世界空间坐标到模型空间坐标的矩阵 unity_ObjectToWorld
				//首先得到模型空间到世界空间的变换矩阵的逆矩阵 unity_WorldToObject
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
				o.color = ambient + diffuse;

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET {
				return fixed4(i.color, 1.0);
			}

			
			ENDCG
		}
	}

	Fallback "Diffuse"
}
