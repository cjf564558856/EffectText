precision highp float;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

varying vec2 textureCoordinate;

uniform float time;

uniform vec2 resolution;

#define PI 3.14159265

const float timeSpan = 0.2;
const float pauseTime = 0.2;
const float switchInterval = 0.1;
const int switchLoops = 9;


void main()
{
    vec4 resultColor = texture2D(inputImageTexture,textureCoordinate);
    lowp vec3 color = texture2D(inputImageTexture,textureCoordinate).rgb;
    float loops = float(switchLoops);
    float totalDuration = timeSpan * 16.0 + pauseTime + loops * switchInterval;
    float newTime = mod(time,totalDuration);
    if(newTime <= totalDuration)
    {
        vec2 aspectRatio_inv = vec2(1.0,resolution.x/resolution.y);
        float rowNum = 3.0;
        vec2 gap = vec2(0.02) * aspectRatio_inv;
        vec2 gridSize = (1.0 - gap * (rowNum - 1.0))/rowNum;
        vec2 gridWithGapSize = gridSize + gap;

        // vec2 modResult = mod(textureCoordinate,gridWithGapSize);
        vec2 devideResult = textureCoordinate/gridWithGapSize;
        ivec2 colRows = ivec2(devideResult);

        vec2 newUV = textureCoordinate - (vec2(colRows) * gridSize + clamp(vec2(colRows), 0.0 ,rowNum) * gap);

        newUV = newUV * 1.0/gridSize;
        if(newUV.x <= 1.0 && newUV.y <= 1.0)
        {
            color = texture2D(inputImageTexture,newUV).rgb;
            float firstLoopIndex = 0.0;
            float extraTime = pauseTime - timeSpan;

            bool timeCondition = (newTime < timeSpan * (firstLoopIndex + 1.0) && newTime >= timeSpan * firstLoopIndex)||
            (newTime < timeSpan * (firstLoopIndex + 9.0) + extraTime && newTime >= timeSpan * (firstLoopIndex + 8.0));
            bool coordCondition = (colRows == ivec2(0));
            bool showGray = true;
            if(timeCondition && coordCondition)
            {
                showGray = false;
            }

            firstLoopIndex = firstLoopIndex + 1.0;
            timeCondition = (newTime < timeSpan * (firstLoopIndex + 1.0) && newTime >= timeSpan * firstLoopIndex)||
            (newTime < timeSpan * (firstLoopIndex + 9.0) + extraTime && newTime >= timeSpan * (firstLoopIndex + 8.0) + extraTime);
            coordCondition = (colRows == ivec2(1,0));
            if(timeCondition && coordCondition)
            {
                showGray = false;
            }

            firstLoopIndex = firstLoopIndex + 1.0;
            timeCondition = (newTime < timeSpan * (firstLoopIndex + 1.0) && newTime >= timeSpan * firstLoopIndex)||
            (newTime < timeSpan * (firstLoopIndex + 9.0) + extraTime && newTime >= timeSpan * (firstLoopIndex + 8.0) + extraTime);
            coordCondition = (colRows == ivec2(2,0));
            if(timeCondition && coordCondition)
            {
                showGray = false;
            }

            firstLoopIndex = firstLoopIndex + 1.0;
            timeCondition = (newTime < timeSpan * (firstLoopIndex + 1.0) && newTime >= timeSpan * firstLoopIndex)||
            (newTime < timeSpan * (firstLoopIndex + 9.0) + extraTime && newTime >= timeSpan * (firstLoopIndex + 8.0) + extraTime);
            coordCondition = (colRows == ivec2(2,1));
            if(timeCondition && coordCondition)
            {
                showGray = false;
            }

            firstLoopIndex = firstLoopIndex + 1.0;
            timeCondition = (newTime < timeSpan * (firstLoopIndex + 1.0) && newTime >= timeSpan * firstLoopIndex)||
            (newTime < timeSpan * (firstLoopIndex + 9.0) + extraTime && newTime >= timeSpan * (firstLoopIndex + 8.0) + extraTime);
            coordCondition = (colRows == ivec2(2,2));
            if(timeCondition && coordCondition)
            {
                showGray = false;
            }
 
            firstLoopIndex = firstLoopIndex + 1.0;
            timeCondition = (newTime < timeSpan * (firstLoopIndex + 1.0) && newTime >= timeSpan * firstLoopIndex)||
            (newTime < timeSpan * (firstLoopIndex + 9.0) + extraTime && newTime >= timeSpan * (firstLoopIndex + 8.0) + extraTime);
            coordCondition = (colRows == ivec2(1,2));
            if(timeCondition && coordCondition)
            {
                showGray = false;
            }

            firstLoopIndex = firstLoopIndex + 1.0;
            timeCondition = (newTime < timeSpan * (firstLoopIndex + 1.0) && newTime >= timeSpan * firstLoopIndex)||
            (newTime < timeSpan * (firstLoopIndex + 9.0) + extraTime && newTime >= timeSpan * (firstLoopIndex + 8.0) + extraTime);
            coordCondition = (colRows == ivec2(0,2));
            if(timeCondition && coordCondition)
            {
                showGray = false;
            }

            firstLoopIndex = firstLoopIndex + 1.0;
            timeCondition = (newTime < timeSpan * (firstLoopIndex + 1.0) && newTime >= timeSpan * firstLoopIndex)||
            (newTime < timeSpan * (firstLoopIndex + 9.0) + extraTime && newTime >= timeSpan * (firstLoopIndex + 8.0) + extraTime);
            coordCondition = (colRows == ivec2(0,1));
            if(timeCondition && coordCondition)
            {
                showGray = false;
            }

            firstLoopIndex = firstLoopIndex + 1.0;
            // timeCondition = newTime >= timeSpan * (firstLoopIndex + 8.0) + extraTime;
            timeCondition = (newTime >= timeSpan * (firstLoopIndex + 8.0) + extraTime && newTime < totalDuration - loops * switchInterval) ||
            (newTime >= totalDuration - 6.0 * switchInterval && newTime < totalDuration - switchInterval * 5.0) ||
            (newTime >= totalDuration - 4.0 * switchInterval && newTime < totalDuration - switchInterval * 3.0) ||
            (newTime >= totalDuration - 2.0 * switchInterval && newTime < totalDuration - switchInterval);
            coordCondition = (colRows == ivec2(1,1));
            if(timeCondition && coordCondition)
            {
                showGray = false;
            }
            if(showGray)
            {
                vec3 rgb2gray = vec3(0.299,0.587,0.114);
                float gray = dot(color,rgb2gray);
                color = vec3(gray);
            }

            resultColor.rgb = color;
            resultColor.a = texture2D(inputImageTexture,newUV).a;
        }
        else
        {
            color = vec3(0.0);
            resultColor.rgb = color;
        }

        // scale progress
        // if(newTime >= totalDuration - scaleTime)
        // {
        //     float scaleProgress = (newTime - (totalDuration - scaleTime))/scaleTime;
        //     vec2 scaleGridSize = (1.0 - gridSize) *scaleProgress + gridSize;
        //     vec2 center = vec2(0.5);
        //     vec2 leftTop = center - scaleGridSize * 0.5;
        //     vec2 scaleUV = textureCoordinate - leftTop;
        //     if(scaleUV.x >= 0.0 && scaleUV.x <=  scaleGridSize.x && scaleUV.y >= 0.0 && scaleUV.y < scaleGridSize.y)
        //     {
        //         scaleUV = scaleUV/(scaleGridSize);
        //         color = texture2D(inputImageTexture,scaleUV).rgb;
        //     }
                     
        // }
                   
    }

    gl_FragColor = resultColor;
}
