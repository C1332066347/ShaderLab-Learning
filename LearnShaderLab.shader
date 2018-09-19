// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
//MVP转换全称：Model * View * Projection Matrix 模型视图投影矩阵转换
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Demo" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _MainColor ("Color Tint", Color) = (1, 1, 1, 1)
        _Cutoff ("CutOff", Range(0, 1)) = 0.5
    }

    SubShader {
        //[Tags]定义标签，Queue表示渲染顺序，制定物体属于哪一个渲染队列，通过这种方式可以保证所有的透明物体可以在所有不透明物体后面
        //被渲染， 
        
        Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
        
        /*
        RenderType 对着色器进行分类
        Opaque: 用于大多数着色器（法线着色器、自发光着色器、反射着色器以及地形的着色器）。
        Transparent:用于半透明着色器（透明着色器、粒子着色器、字体着色器、地形额外通道的着色器）。
        TransparentCutout: 蒙皮透明着色器（Transparent Cutout，两个通道的植被着色器）。
        Background: Skybox shaders. 天空盒着色器。
        Overlay: GUITexture, Halo, Flare shaders. 光晕着色器、闪光着色器。
        TreeOpaque: terrain engine tree bark. 地形引擎中的树皮。
        TreeTransparentCutout: terrain engine tree leaves. 地形引擎中的树叶。
        TreeBillboard: terrain engine billboarded trees. 地形引擎中的广告牌树。
        Grass: terrain engine grass. 地形引擎中的草。
        GrassBillboard: terrain engine billboarded grass. 地形引擎何中的广告牌草。
        */
        //IgnoreProjector 如果标签值为True，那么使用该SubShader的物体将不会收到Projector的影响， 通常用于半透明物体
        //Projector能将一个Material投影到所有在设定的平截头体内的物体上。
        pass {
            //[Name] 该通道的名称， 例如 Name "MyPassName" 可以在其他着色器中直接使用该通道，用法为UsePass "Demo/MYPASSNAME"
            //这样可以提高代码的复用性， Unity内部会把所有Pass的名称转换成大写字母的表示，因此，在使用UsePass指令时，必须使用大写形式的名字

            //[Tags] Pass 同样也可以设置标签
            //LightMode 指定Pass和Unity 的哪一种渲染路径搭配使用，
            /*Always: Always rendered; no lighting is applied. 永远都渲染，但不处理光照

            ***ForwardBase: Used in Forward rendering, ambient, main directional light, vertex/SH lights and lightmaps are applied. 
            被使用在前向渲染，环境光照，主方向光照，vertex顶点光照（效果最差，默认只有一个光照）
            unity的渲染路径有四种，Deferred(延迟渲染，效果最好), Forward(正向渲染), Vertex(定点光照)，shader没有写专门
            支持Deferred的就会自动寻找Forward，没有Forward就寻找Vertex（Vertex是最基本的，如果还没有，就不显示了，一般是不会发生的，因为你不声明LightMode模式默认都是支持Vertex的）

            ***ForwardAdd: Used in Forward rendering; additive per-pixel lights are applied, one pass per light. 
            ForwardBase 和 ForwardAdd是专门为Forward渲染路径下渲染物体而设计的两种Pass，其中ForwardBase会先于ForwardAdd被执行
            这两种类型的Pass在Forward渲染路径下有着不同的光照处理功能，参考 https://www.2cto.com/kf/201605/505657.html


            Deferred: Used in Deferred Shading; renders g-buffer. 
            ShadowCaster: Renders object depth into the shadowmap or a depth texture. 
            PrepassBase: Used in legacy Deferred Lighting, renders normals and specular exponent. 
            PrepassFinal: Used in legacy Deferred Lighting, renders final color by combining textures, lighting and emission. 
            Vertex: Used in legacy Vertex Lit rendering when object is not lightmapped; all vertex lights are applied. 
            VertexLMRGBM: Used in legacy Vertex Lit rendering when object is lightmapped; on platforms where lightmap is RGBM encoded (PC & console). 
            VertexLM: Used in legacy Vertex Lit rendering when object is lightmapped; on platforms where lightmap is double-LDR encoded (mobile platforms).*/
            
            //基本渲染路径顺序是：
            //1.Deferred :Deferred >Forward>Vertex
            //2.Forward:Forward>Vertex
            //3.Vertex:Vertex
            
            
            Tags { "LightMode" = "ForwardBase"}

            CGPROGRAM //CG程序开始标志，在这之间使用CG/HLSL语言来编写顶点/片元着色器
            //除了 surfaceshader vertext/fragment(shader) 还有一种固定函数着色器，它是有固定的几个函数，每个函数只能完成
            //固定的功能，只能完成一些简单的效果,并且要完全使用ShaderLab语言(而非CG/HLSL)进行编写，但本质还是顶点/片元着色器，总体来说，只有vertex/fragment 着色器一种，其他的是对它的再封装

            //编译指令
            //Vertex函数 将物体的点和像素传进来
            #pragma vertex vert
            //对顶点和片元进行渲染
            #pragma fragment frag
            //Lighting.cginc包含了各种内置的光照模型，如果是surface shader会自动包进来
            //UnityShaderVariables.cginc 会自动包进来，包含了许多内置的全局变量，如UNITY_MATRIX_MVP等
            //HLSLSupport.cginc 在编译Unity Shader时，自动包进来， 声明了很多用于跨平台编译的宏，和定义
            #include "Lighting.cginc"

                fixed4 _MainColor;
                sampler2D _MainTex;
                float _Cutoff;
                float4 _MainTex_ST;
                //输入参数结构体，定义顶点着色器的输入 a2v 表示 把数据从 application (应用)阶段传递到顶点着色器中v 表示 vertex shader 
                struct a2v {
                    //vertex,顶点坐标，由于所有的3D物体都是由三角形构成的，所以在渲染时，传入每一个三角形的顶点，POSITION则是用于指定
                    //传入的顶点,返回值是一个float4的变量，它是该顶点在裁剪空间中的位置，SV_POSITION和POSITION都是语义，用于告诉系统
                    //用户需要那些输入值，以及用户的输出是什么，例如POSITION是将告诉UNITY，把模型的顶点坐标填充到输入参数中，
                    //SV_POSITION 将告诉Unity 定点着色器的输出是裁剪空间(https://blog.csdn.net/ad88282284/article/details/78245719?locationNum=9&fps=1)中的顶点坐标
                    //POSITION 告诉unity，用模型空间的顶点坐标填充vertex变量
                    float4 vertex : POSITION;
                    //NORMAL语义告诉untiy 用模型空间的法线方向填充normal变量
                    float3 normal : NORMAL;
                    //TEXCOORD0告诉unity 用第一套纹理的坐标填充texcoord变量
                    float4 texcoord : TEXCOORD0;
                };
                //unity 对于模型的每一个顶点，都要进行一次输入，所以每次输入的是当前顶点的，坐标，法线方向，模型的第n套纹理的坐标
                
                //v2f 表示把数据从vertex shader 中传递到fragment shader中
                struct v2f {
                    //SV_POSITION 语义告诉unity， pos 里包含了顶点在裁剪空间中的位置信息， 在传入坐标进行处理后放到pos里进行输出
                    //顶点着色器的输出结构中必须包含一个SV_POSITION语义的变量，否则渲染器无法得到裁剪空间中的顶点坐标
                    float4 pos : SV_POSITION;
                    //NORMAL经处理后的法线向量存在worldNormal变量中进行输出
                    float3 worldNormal : NORMAL;

                    float3 worldPos : TEXCOORD1;
                    float2 uv : TEXCOORD2;
                };
                //渲染流程前部分是坐标变换，顺序是：模型空间->世界空间->观察空间->裁剪控件->屏幕空间
                /*UNITY_MATRIX_MVP        当前模型视图投影矩阵
                UNITY_MATRIX_MV           当前模型视图矩阵
                UNITY_MATRIX_V              当前视图矩阵。
                UNITY_MATRIX_P              目前的投影矩阵
                UNITY_MATRIX_VP            当前视图*投影矩阵
                UNITY_MATRIX_T_MV       移调模型视图矩阵
                UNITY_MATRIX_IT_MV      模型视图矩阵的逆转
                UNITY_MATRIX_TEXTURE0   UNITY_MATRIX_TEXTURE3          纹理变换矩阵*/
                //这里传入顶点,法线
                v2f vert (a2v v) {
                    v2f o;
                    //UnityObjectToClipPos函数将顶点的模型空间的坐标转换为投影空间的坐标并填充到o.pos
                    o.pos = UnityObjectToClipPos(v.vertex);
                    //把顶点的模型空间的法线向量转化为世界坐标系中，并存储到o.worldNormal变量中
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    //https://blog.csdn.net/cheng624/article/details/52638283
                    //UNITY_MATRIX_MVP矩阵是Unity 内置的模型·观察·投影矩阵，书第四章，重点了解下
                    //将模型空间的坐标转换为世界空间坐标的xyz存储到o.worldPos变量中
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    //将模型顶点的uv和Tiling、Offset两个变量进行运算，计算出实际显示用的顶点UV
                    //v.texcoord是模型顶点的uv数据，_MainTex是使用的图片
                    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                    //TRANSFORM_TEX的作用是用顶点的UV v.texcoord和材质球的采样图片_MainTex做运算，确保顶点材质球里的缩放和偏移是正确的。

                    return o;
                }
                    //SV_TARGET语义是HLSL中的一个系统语义，等同于告诉渲染器，把用户的输出颜色存储到一个渲染目标，
                    //这里返回一个值，它存储了用户的输出颜色，即当前传入的点经过一系列的运算后得出一个颜色，对它进行存储并输出
                    //这是显示在屏幕上的颜色
                fixed4 frag (v2f i) : SV_TARGET {
                    //归一化向量，即将有量纲的值转化为无量纲的值，即标量
                    fixed3 worldNormal = normalize(i.worldNormal);
                    //
                    fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                    fixed4 texColor = tex2D(_MainTex, i.uv);
                    clip(texColor.a - _Cutoff);
                    fixed3 albedo = texColor.rgb * _MainColor.rgb;
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                    fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                    return fixed4(ambient + diffuse, 1.0);
                }        
                
            ENDCG
        }
    }
    Fallback "Transparent/Cutout/VertexLit"
}