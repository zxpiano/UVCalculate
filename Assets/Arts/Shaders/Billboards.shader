Shader "ZxP/Billboards"
{
    Properties
    {
        [HDR] _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo[RGB]", 2D) = "white" {}
        _Row("广告行数", int) = 2
        _Column("广告列数", int) = 4

        [Enum(JumpSwitch,0,Translation,1,Gradient,2,Distort,3)] _Option("广告切换模式", Int) = 0

        _GradientTime("多久后开始进行变换", Range(0.01,1)) = 0.5
        _ChangeSpeed("广告切换速度", Range(0,20)) = 10

        _DistortAnima("扰动渐变动画",2D) = "white" {}
        _DistorRow("扰动图行数",int) = 2
        _DistorColumn("扰动图列数",int) = 5

        // 扰动 led
        _DistortPower("Distort Power", Range(0 , 1)) = 0
        _Distortions("Distortions", 2D) = "white" {}
        _LED("LED", 2D) = "white" {}
        _LEDGlow("LED Glow", 2D) = "white" {}
        _GlitchIntensity("Glitch Intensity", Range(0 , 1)) = 0
        _Glitch1("Glitch1", Color) = (0.5197807,0.4306336,0.9926471,0)
        _Glitch2("Glitch2", Color) = (0.5588235,0.08093307,0,0)
        _LEDint("LED int", Range(0 , 1)) = 0



        // ------------------Emission--------------------
        [HDR]_EmissionColor("Emisson Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4   _Color;
            half3   _EmissionColor;
            float   _ChangeSpeed;
            float   _GradientTime;
            int     _Option;
            int     _Row;
            int     _Column;

            sampler2D _DistortAnima;
            float4 _DistortAnima_ST;
            int _DistorRow;
            int _DistorColumn;

            uniform float _DistortPower;
            uniform sampler2D _Distortions;
            uniform sampler2D _LED;
            uniform sampler2D _LEDGlow;
            uniform float _GlitchIntensity;
            uniform float4 _Glitch1;
            uniform float4 _Glitch2;
            uniform float _LEDint;



            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // 噪声效果
                float2 fixUV = i.uv;
                float2 uv0 = (1.0 * _Time.y * float2(1, 2) + fixUV);
                float2 uv1 = (1.0 * _Time.y * float2(-1.8, 0.3) + fixUV);
                float2 uv2 = (1.0 * _Time.y * float2(0.8, -1.5) + fixUV);
                float2 uv3 = (1.0 * _Time.y * float2(-0.8, -1.5) + fixUV);
                float4 led = tex2D(_LED, fixUV);

                float2 uv4 = (1.0 * _Time.y * float2(-6, 5) + fixUV);
                float glitch = clamp((_GlitchIntensity + tex2D(_LEDGlow, uv4).a), 0.0, 1.0);

                float2 uv5 = (1.0 * _Time.y * float2(2, 3) + fixUV);
                float2 uv6 = (1.0 * _Time.y * float2(0, 0.6) + fixUV);
                float sinTime = clamp((0.7 + ((_SinTime.w * (_SinTime.w * 2.5) * (_SinTime.w * 1.3)) - -2.0) * (1.0 - 0.7) / (1.0 - -2.0)), 0.0, 1.0);

                float2 uv7 = (1.0 * _Time.y * float2(-5, -2.3) + fixUV);
                //float2 panner = float2(_PannerX, _PannerY);
                float2 uv8 = (1.0 * _Time.y * float2(0.8, -1.5) + fixUV);

                float4 glitchLed = glitch * (((_Glitch1* tex2D(_LEDGlow, uv5).g) + ((_Glitch2 * tex2D(_LEDGlow, uv6).r) + (led * sinTime)))* _LEDint);

                float distortions = ((((tex2D(_Distortions, uv0).r + tex2D(_Distortions, uv1).g) + tex2D(_Distortions, uv2).b) + tex2D(_Distortions, uv3).a) * (0.0 + (_DistortPower - 0.0) * (0.5 - 0.0) / (1.0 - 0.0)));
                //return distortions;
                // 切换
                half2 adUVStep = half2(1.0 / _Row, 1.0 / _Column); // 广告uv每次更换得步长，和广告贴图上的行列个数有关

                float2 uv = float2(i.uv.x * adUVStep.y, i.uv.y * adUVStep.x);
                float time = _Time.x * _ChangeSpeed;
                int perstep = fmod(time, (_Row * _Column)); // 以2行4列为例 对8取余 0~7;
                float3 check = float3(1, 1, 1);

                half uvOffsetX;
                half uvOffsetY;
                float decimalTime = 0;  // 存时间的小数位
                float timeCompensate = 0;   // 存加快时间的倍率

                // 直接变换切换广告
                if (_Option == 0)
                {
                    //check = float3(1, 0, 0);
                    uvOffsetX = adUVStep.y * perstep;
                    uvOffsetY = adUVStep.x * int(perstep / _Column); // 以2行4列为例，0~7 除以4 取商，0~3得0，4~7得1
                }


                // 平移切换广告
                if (_Option == 1)
                {
                    decimalTime = frac(time);   // 时间取小数
                    timeCompensate = (1 / (1 - _GradientTime)); //  时间加快的倍率为 进行变化使用的时间的倒数
                    if ((perstep + 1) % _Column != 0 || _Row == 1)  // 有多行的广告贴图，u向边界 1 处的图不进行平移变换
                    {
                        if (decimalTime > _GradientTime)
                        {
                            //check = float3(0, 1, 0);
                            uvOffsetX = adUVStep.y * (perstep + frac((decimalTime - _GradientTime) * timeCompensate));
                        }
                    }
                }

                uv.x += uvOffsetX;
                uv.y += uvOffsetY;
                float4 albedo = tex2D(_MainTex, uv + distortions);


                // 渐变切换广告
                if (_Option == 2)
                {
                    decimalTime = frac(time);   // 时间取小数
                    timeCompensate = (1 / (1 - _GradientTime)); //  时间加快的倍率为 进行变化使用的时间的倒数
                    float2 uvTemp = float2(adUVStep.y, ((perstep + 1) % _Column == 0) ? adUVStep.x : 0);
                    float2 nextUV = uv + uvTemp;
                    float4 ad1;
                    float4 ad2;
                    ad1 = tex2D(_MainTex, uv + distortions);
                    ad2 = tex2D(_MainTex, nextUV + distortions);
                    if (decimalTime > _GradientTime)
                    {
                        //check = float3(0, 0, 1);
                        //return frac((frac(_Time.x * _ChangeSpeed) - _GradientTime) * (1 / (1 - _GradientTime)));
                        float switchTime = frac((decimalTime - _GradientTime) * timeCompensate);
                        float4 black = float4(0, 0, 0, 1);

                        if (switchTime <= 0.5)
                        {
                            albedo = lerp(ad1, black, saturate(2 * switchTime));
                        }
                        else
                        {
                            albedo = lerp(black, ad2, saturate(2 * switchTime - 1));
                        }
                    }
                }

                // 扰动 渐变 切换广告
                if (_Option == 3)
                {
                    float noise = tex2D(_DistortAnima, i.uv).r;

                    decimalTime = frac(time);   // 时间取小数
                    timeCompensate = (1 / (1 - _GradientTime)); //  时间加快的倍率为 进行变化使用的时间的倒数
                    float2 uvTemp = float2(adUVStep.y, ((perstep + 1) % _Column == 0) ? adUVStep.x : 0);
                    float2 nextUV = uv + uvTemp;
                    float4 ad1;
                    float4 ad2;
                    ad1 = tex2D(_MainTex, uv + distortions);
                    ad2 = tex2D(_MainTex, nextUV + distortions);
                    if (decimalTime > _GradientTime)
                    {
                        //check = float3(0, 0, 1);
                        //return frac((frac(_Time.x * _ChangeSpeed) - _GradientTime) * (1 / (1 - _GradientTime)));
                        float switchTime = frac((decimalTime - _GradientTime) * timeCompensate);

                        float2 distorUV = i.uv * _DistortAnima_ST.xy + _DistortAnima_ST.zw;
                        //distorUV.y = 1 - distorUV.y;
                        float allFilmes = _DistorRow * _DistorColumn;    // 64个序列帧  8 * 8 
                        float invRows = 1.0 / _DistorRow;   // 1 / 8; 行列一样
                        float invColumns = 1.0 / _DistorColumn;
                        float2 stepUV = float2(invColumns, invRows);
                        distorUV *= stepUV;

                        float currentIndex = fmod(switchTime, allFilmes);

                        distorUV += float2(stepUV.x * int(currentIndex * allFilmes), stepUV.y * int(int(currentIndex * allFilmes) * invColumns));
                        float distortGradient = tex2D(_DistortAnima, distorUV);


                        float temp = smoothstep(0, 1, noise - switchTime);
                        temp = step(switchTime, noise);
                        //return temp;
                        albedo = lerp(ad2, ad1, temp);
                    }

                }


                albedo.xyz *= _Color.xyz;

                float3 finalColor = albedo.xyz;



                // EMISSION--------
                float3 EmissionCol = albedo.rgb * _EmissionColor.rgb;
                finalColor += EmissionCol + glitchLed.xyz;

                //---------------------


                return float4(finalColor, 1);
            }
            ENDCG
        }
    }
}
