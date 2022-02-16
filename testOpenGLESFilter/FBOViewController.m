//
//  FBOViewController.m
//  testOpenGLESFilter
//
//  Created by IGG on 2021/10/19.
//  Copyright © 2021 Lyman Li. All rights reserved.
//

#import "FBOViewController.h"

#import <GLKit/GLKit.h>
#import <string.h>
#import "FilterBar.h"


typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord; // (U, V)
} SenceVertex;
#define AlphaType  0
#define ScaleType  1
#define RotateType 2
#define PosType    3
#define BlurType   4
typedef struct {
    int type;
    float start;
    float end;
    float startFrom;
    float endTo;
} Transform;


@interface FBOViewController () <FilterBarDelegate>

@property (nonatomic, assign) SenceVertex *vertices;
@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, strong) CADisplayLink *displayLink; // 用于刷新屏幕
@property (nonatomic, assign) NSTimeInterval startTimeInterval; // 开始的时间戳

@property (nonatomic, assign) GLuint program; // 着色器程序
@property (nonatomic, assign) GLuint program2; // 着色器程序2
@property (nonatomic, assign) GLuint vertexBuffer; // 顶点缓存
@property (nonatomic, assign) GLuint textureID; // 纹理 ID
@property (nonatomic, assign) GLuint texture2ID; // 纹理2 ID
@property (nonatomic, assign) GLuint texture3ID; // 纹理3 ID
@property (nonatomic, assign) GLuint texture4ID; // 纹理4 ID
@property (nonatomic, assign) GLuint texture5ID; // 纹理5 ID
@property (nonatomic, assign) GLuint texture6ID; // 纹理6 ID
@property (nonatomic, assign) GLuint framebufferID; //帧缓存 ID
@property (nonatomic, assign) GLuint framebuffer2ID; //帧缓存2 ID

@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, strong) NSMutableArray *actions;

@property (nonatomic, strong) UIImage *viewImage;
@property (nonatomic, strong) UIImage *maskImage;
@property (nonatomic, strong) UIImage *effectImage;

@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, assign) NSUInteger imageIndex;
@property (nonatomic, assign) BOOL isTextCode;

@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) CGFloat viewHeight;

@end


@implementation FBOViewController

- (void)dealloc {
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
    if (_vertices) {
        free(_vertices);
        _vertices = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [self setupFilterBar];
    
    [self commonInit];
    
    [self startFilerAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 移除 displayLink
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

-(NSMutableArray *)imageArray{
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

- (void)commonInit {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
    
    self.actions = [NSMutableArray arrayWithCapacity:10];
    
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"sample.jpg"];
    
    NSString *maskPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mask.png"];
    
    NSString *maskPath1 = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mask1.png"];

    NSString *effectPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"camera.png"];
    
    self.viewImage = [UIImage imageWithContentsOfFile:imagePath];
    self.maskImage = [UIImage imageWithContentsOfFile:maskPath];
    self.effectImage = [UIImage imageWithContentsOfFile:effectPath];
    
    self.vertices = malloc(sizeof(SenceVertex) * 4);
    self.vertices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}};
    self.vertices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}};
    self.vertices[2] = (SenceVertex){{1, 1, 0}, {1, 1}};
    self.vertices[3] = (SenceVertex){{1, -1, 0}, {1, 0}};
    
    float r = self.viewImage.size.width > self.viewImage.size.height ? (float)self.viewImage.size.height / (float)self.viewImage.size.width :
        (float)self.viewImage.size.width / (float)self.viewImage.size.height;
    if (self.viewImage.size.width >= self.viewImage.size.height) {
//        self.vertices[0] = (SenceVertex){{-1, r, 0}, {0, 1}};
//        self.vertices[1] = (SenceVertex){{-1, -r, 0}, {0, 0}};
//        self.vertices[2] = (SenceVertex){{1, r, 0}, {1, 1}};
//        self.vertices[3] = (SenceVertex){{1, -r, 0}, {1, 0}};
        self.viewWidth = self.view.frame.size.width;
        self.viewHeight = self.view.frame.size.width * r;
    } else {
//        self.vertices[0] = (SenceVertex){{-r, 1, 0}, {0, 1}};
//        self.vertices[1] = (SenceVertex){{-r, -1, 0}, {0, 0}};
//        self.vertices[2] = (SenceVertex){{r, 1, 0}, {1, 1}};
//        self.vertices[3] = (SenceVertex){{r, -1, 0}, {1, 0}};
        self.viewWidth = self.view.frame.size.width * r;
        self.viewHeight = self.view.frame.size.width;
    }
    

    CAEAGLLayer *layer = [[CAEAGLLayer alloc] init];
    
    layer.frame = CGRectMake(0, 100, self.viewWidth, self.viewHeight);
    layer.contentsScale = [[UIScreen mainScreen] scale];
    
    [self.view.layer addSublayer:layer];
    
    [self bindRenderLayer:layer];
    
    [self createFrameBuffer];
    
    GLuint textureID = [self createTextureWithImage:self.viewImage];
    self.textureID = textureID;  // 将纹理 ID 保存，方便后面切换滤镜的时候重用
    
    GLuint maskTexture = [self createTextureWithImage:self.maskImage];
    self.texture3ID = maskTexture;
    
    GLuint mask1Texture = [self createTextureWithImage:[UIImage imageWithContentsOfFile:maskPath1]];
    self.texture5ID = mask1Texture;
    
    GLuint effectTexture = [self createTextureWithImage:self.effectImage];
    self.texture4ID = effectTexture;
    
    //支持混合
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_DEPTH_TEST);

    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * 4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);

    [self setupNormalShaderProgram]; // 一开始选用默认的着色器
    
    self.vertexBuffer = vertexBuffer; // 将顶点缓存保存，退出时才释放
}

- (GLuint)createTextureWithImage:(UIImage *)image {
    
    //解压成位图
    CGImageRef cgImageRef = [image CGImage];
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImageRef);
    
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    CGContextRelease(context);
    free(imageData);
    
    return textureID;
}

- (void)bindRenderLayer:(CALayer <EAGLDrawable> *)layer {
    GLuint renderBuffer;
    GLuint frameBuffer;
    
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER,
                              renderBuffer);
    self.framebufferID = frameBuffer;
}

- (void)createFrameBuffer {
    GLuint textureBuffer;
    GLuint frameBuffer;
    glGenTextures(1, &textureBuffer);
    glBindTexture(GL_TEXTURE_2D, textureBuffer);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.drawableWidth, self.drawableHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    //将FBO与texture2D链接,使用一个缓存来暂时保存当前处理好的画面储存到一个贴图中，以便后续处理
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureBuffer, 0);
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE){
        printf("create frame buffer has been successful\n");
        self.texture2ID = textureBuffer;
        self.framebuffer2ID = frameBuffer;
    }
}

- (GLuint)programWithShaderName:(NSString *)shaderName {
    GLuint vertexShader = [self compileShaderWithName:shaderName type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShaderWithName:shaderName type:GL_FRAGMENT_SHADER];
    
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    glLinkProgram(program);
    
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"program链接失败：%@", messageString);
        exit(1);
    }
    return program;
}

- (GLuint)compileShaderWithName:(NSString *)name type:(GLenum)shaderType {
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:name ofType:shaderType == GL_VERTEX_SHADER ? @"vsh" : @"fsh"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSAssert(NO, @"读取shader失败");
        exit(1);
    }
    
    GLuint shader = glCreateShader(shaderType);
    
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shader, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shader);
    
    GLint compileSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shader, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"shader编译失败：%@", messageString);
        exit(1);
    }
    
    return shader;
}

- (GLint)drawableWidth {
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    
    return backingWidth;
}

- (GLint)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    return backingHeight;
}

// 创建滤镜栏
- (void)setupFilterBar {
    CGFloat filterBarWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat filterBarHeight = 100;
    CGFloat filterBarY = [UIScreen mainScreen].bounds.size.height - filterBarHeight;
    FilterBar *filerBar = [[FilterBar alloc] initWithFrame:CGRectMake(0, filterBarY, filterBarWidth, filterBarHeight)];
    filerBar.delegate = self;
    [self.view addSubview:filerBar];
    
    NSArray *dataSource = @[@"无", @"缩放", @"灵魂出窍", @"抖动", @"闪白", @"毛刺", @"幻觉", @"放大", @"旋转", @"下降", @"边缘", @"荧光", @"交错", @"丁达尔", @"彩色线条", @"相机焦点", @"彩虹", @"高斯模糊", @"定向模糊", @"径向模糊", @"锐化", @"边角定位", @"贝塞尔变形",@"残影+彩色线条",@"残影+彩虹",@"残影+线位移"];
    filerBar.itemList = dataSource;
}

// 开始一个滤镜动画
- (void)startFilerAnimation {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    
    self.startTimeInterval = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeAction)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSRunLoopCommonModes];
}

//GLuint createVBO(GLenum target, int usage, int datSize, void *data)
//{
//    GLuint vbo;
//    glGenBuffers(1, &vbo);
//    glBindBuffer(target, vbo);
//    glBufferData(target, datSize, data, usage);
//    return vbo;
//}

- (NSArray*)getBezierValue:(CGFloat[])controls :(CGFloat)t {
    CGFloat xc1 = controls[0];
    CGFloat yc1 = controls[1];
    CGFloat xc2 = controls[2];
    CGFloat yc2 = controls[3];

    NSNumber *num1 = [NSNumber numberWithFloat:3 * xc1 * (1 - t) * (1 - t) * t + 3 * xc2 * (1 - t) * t * t + t * t * t];
    NSNumber *num2 = [NSNumber numberWithFloat:3 * yc1 * (1 - t) * (1 - t) * t + 3 * yc2 * (1 - t) * t * t + t * t * t];
    NSArray *arr = [NSArray arrayWithObjects:num1, num2, nil];
    return arr;
}

- (CGFloat)getBezierTfromX:(CGFloat[])controls :(CGFloat) x{
    CGFloat ts = 0.0;
    CGFloat te = 1.0;
    do {
        CGFloat tm = (ts + te) / 2.0;
        NSArray *value = [self getBezierValue:controls:tm];
        CGFloat val = [ value[0] floatValue ];
        if(val > x){te = tm;}else {ts = tm;}
    }while ((te - ts) >= 0.0001);
    return(te + ts) / 2.0;
}

- (CGFloat)toBezier:(float)t :(float)b :(float)c :(float)d {
    CGFloat t1 = t / d;
    CGFloat controls[] = {.17, .87, .41, .96};
    CGFloat tvalue = [self getBezierTfromX:controls:t1];
    NSArray *arr = [self getBezierValue:controls:tvalue];
    CGFloat value = [ arr[1] floatValue ];
    return b + c * value;
}

- (float)toLinear:(float)t :(float)b :(float)c :(float)d{
    float t1 = t / d;
    return b + c * t1;
}

- (void)timeAction {
    if (self.startTimeInterval == 0) {
        self.startTimeInterval = self.displayLink.timestamp;
    }
    
    glUseProgram(self.program);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    glActiveTexture(GL_TEXTURE0);
    //彩色线条
    if(self.currentIndex == 14) {
        glBindTexture(GL_TEXTURE_2D, self.texture3ID);
    }else{
        glBindTexture(GL_TEXTURE_2D, self.textureID);
    }
    //交错 彩虹
    if (self.currentIndex == 12 || self.currentIndex == 16){
        
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, self.texture3ID);

    }
    //相机
    if (self.currentIndex == 15){
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, self.texture4ID);
    }
    
    if (self.currentIndex == 23){
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, self.textureID);
//
//        glActiveTexture(GL_TEXTURE1);
//        glBindTexture(GL_TEXTURE_2D, self.texture5ID);
    }
    
    if (self.currentIndex == 24){
        //残影+彩虹：第一次需要原图和抠像图一
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, self.textureID);

        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, self.texture3ID);
    }
    
    if (self.currentIndex == 25){
        //残影+线位移：第一次需要原图和抠像图一
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, self.textureID);

        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, self.texture3ID);
    }
    
    
//    if (self.currentIndex >= 26 && self.currentIndex != 41) {
//        if (self.isTextCode) {
//
//            if (self.currentIndex == 40) {
//
//                //先解压成位图，生成纹理单元，在需要的时候，获取当前着色器程序对应的插槽，激活待使用的纹理，把纹理单元设置为要使用的2d纹理，最后给这个插槽传递当前纹理
//                //获取当前着色器程序对应的插槽
//                GLuint textureSlot6 = glGetUniformLocation(self.program, "_BgMainTex");
//                //激活待使用的纹理
//                glActiveTexture(GL_TEXTURE1);
//                //把纹理单元设置为是待使用的2d纹理
//                glBindTexture(GL_TEXTURE_2D, self.texture6ID);
//                //给这个插槽传递当前纹理，为当前程序对象指定同一变量的值
//                //参数一：指定将要被修改的位置
//                //参数二:指定即将要使用的新值
//                glUniform1i(textureSlot6, 1);
//            }else if (self.currentIndex == 41){
//            }
//
//            if (self.imageArray.count > 0) {
//                if (self.imageIndex >=(self.imageArray.count - 1) * 3) {
//                    self.imageIndex = 0;
//                }else{
//                    self.imageIndex++;
//                }
//
//                GLuint textureSlot5 = glGetUniformLocation(self.program, "_MainTex");
//
//                glActiveTexture(GL_TEXTURE2);
//
//                [self updateTextureWithImageIndex:self.imageIndex/3];
//
//                glBindTexture(GL_TEXTURE_2D, self.texture5ID);
//                glUniform1i(textureSlot5, 2);
//
//            }
//        }
//    }
    
    
    
    if(self.currentIndex == 10 || self.currentIndex == 11 || self.currentIndex == 14 || self.currentIndex == 23 || self.currentIndex == 24 || self.currentIndex == 25) {
        //第一次渲染将模型绘制到FBO上
        glBindFramebuffer(GL_FRAMEBUFFER, self.framebuffer2ID);
    }else{
        glBindFramebuffer(GL_FRAMEBUFFER, self.framebufferID);
    }
    
    // 清除画布
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0, 0, 0, 0);
    //printf("time %f\n", time);
    
    // 传入时间
    CGFloat currentTime = self.displayLink.timestamp - self.startTimeInterval;
    GLuint time = glGetUniformLocation(self.program, "time");
    glUniform1f(time, currentTime);
    
    
    if ( self.currentIndex >= 7 && (self.currentIndex != 10 && self.currentIndex != 11 && self.currentIndex != 14) ) {
        float d = 2.f;
        float t = fmodf(currentTime, d);
        float k = t / d;
        //printf("t %f k %f\n", t, k);
        for (NSValue *item in self.actions){
            Transform tr;
            [item getValue: &tr];
            
            if(tr.start < k && k <= tr.end) {
                if (tr.type == ScaleType) {
                    GLuint scaleSlot = glGetUniformLocation(self.program, "scale");
                    float s = [self toLinear:(t - tr.start * d)
                                    :tr.startFrom
                                    :(tr.endTo - tr.startFrom)
                                    :d*(tr.end - tr.start)];
                    glUniform1f(scaleSlot, s);
                    
                }
                else if (tr.type == RotateType) {
                    GLuint transformSlot = glGetUniformLocation(self.program, "transform");
                    float theta = [self toBezier:(t - tr.start * d)
                                   :tr.startFrom
                                   :(tr.endTo - tr.startFrom)
                                   :d*(tr.end - tr.start)];
                    GLKMatrix4 mMatrix = GLKMatrix4Identity;
                    GLKMatrix4 sMatrix = GLKMatrix4MakeScale(self.viewWidth/2, self.viewHeight/2, 1);
                    GLKMatrix4 oMatrix = GLKMatrix4MakeOrtho(-self.viewWidth/2, self.viewWidth/2, -self.viewHeight/2, self.viewHeight/2, -1, 1);
                    mMatrix = GLKMatrix4Multiply(sMatrix, mMatrix);
                    GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(theta, 0.0, 0.0, theta > 0.f ? 1.0 : -1.0);
                    GLKMatrix4 transformMatrix = GLKMatrix4Multiply(rotateMatrix, mMatrix);
                    transformMatrix = GLKMatrix4Multiply(oMatrix, transformMatrix);
                    glUniformMatrix4fv(transformSlot, 1, GL_FALSE, transformMatrix.m);
//                    float s = sin(theta);
//                    float c = cos(theta);
//                    GLfloat T[] = {
//                        c, -s, 0.f, 0.f,
//                        s, c, 0.f, 0.f,
//                        0.f, 0.f, 1.f, 0.f,
//                        0.f, 0.f, 0.f, 1.f,
//                    };
//                    glUniformMatrix4fv(transformSlot, 1, GL_FALSE, (GLfloat *)&T);
                }
                else if (tr.type == PosType) {
                    GLuint translateSlot = glGetUniformLocation(self.program, "translate");
                    float a = [self toLinear:(t - tr.start * d)
                                    :tr.startFrom
                                    :(tr.endTo - tr.startFrom)
                                    :d*(tr.end - tr.start)];
                    GLfloat translate[] = {0.f, a};
                    //GLfloat translate[] = {a, 0.f};
                    glUniform2fv(translateSlot, 1, (GLfloat *)&translate[0]);
                }
                else if (tr.type == AlphaType) {
                    GLuint alphaSlot = glGetUniformLocation(self.program, "alpha");
                    float a = [self toLinear:(t - tr.start * d)
                                    :tr.startFrom
                                    :(tr.endTo - tr.startFrom)
                                    :d*(tr.end - tr.start)];
                    glUniform1f(alphaSlot, a);
                }
                else if (tr.type == BlurType) {
                    GLuint blurStepSlot = glGetUniformLocation(self.program, "blurStep");
                    float a = [self toBezier:(t - tr.start * d)
                                    :tr.startFrom
                                    :(tr.endTo - tr.startFrom)
                                    :d*(tr.end - tr.start)];
                    glUniform1f(blurStepSlot, a);
                }
            }
        }
    }
    if ( self.currentIndex == 18 ) {
        float d = 5.f;
        float t = fmodf(currentTime, d);
        float k = t / d;
        GLuint angleSlot = glGetUniformLocation(self.program, "angle");
        GLuint blurSlot = glGetUniformLocation(self.program, "blurStep");
        glUniform1f(angleSlot, k * 360);
        glUniform1f(blurSlot, 20.0);
    }else if( self.currentIndex == 19 ) {
        GLuint numSlot = glGetUniformLocation(self.program, "num");
        glUniform1i(numSlot, 25);
        GLfloat center[] = {0.3, 0.2};
        GLuint centerSlot = glGetUniformLocation(self.program, "center");
        glUniform2fv(centerSlot, 1, (GLfloat *)&center[0]);
        GLuint typeSlot = glGetUniformLocation(self.program, "rotate");
        glUniform1i(typeSlot, true);
    }else if( self.currentIndex == 20 ) {
        GLuint sharpSlot = glGetUniformLocation(self.program, "sharpness");
        glUniform1f(sharpSlot, 100.0);
    }else if( self.currentIndex == 21) {
        GLuint projectSlot = glGetUniformLocation(self.program, "viewProjectionMatrix");
        glUniformMatrix4fv(projectSlot, 1, GL_FALSE, GLKMatrix4Identity.m);
    }else if( self.currentIndex == 22) {
        GLfloat topLeftVex[] = {0.0, 0.0};
        GLfloat topLeftTangentVex[] = {0.3 * self.drawableWidth, self.drawableHeight * -0.2};
        GLfloat topRightVex[] = {0.9 * self.drawableWidth, 0.2 * self.drawableHeight};
        GLfloat topRightTangentVex[] = {0.6 * self.drawableWidth, self.drawableHeight * 0.3};
        GLfloat bottomLeftVex[] = {0.0, self.drawableHeight};
        GLfloat bottomLeftTangentVex[] = {0.3 * self.drawableWidth, self.drawableHeight * 1.2};
        GLfloat bottomRightVex[] = {self.drawableWidth, self.drawableHeight};
        GLfloat bottomRightTangentVex[] = {self.drawableWidth * 0.7, 1.4 * self.drawableHeight};
        
        GLfloat leftTopTangentVex[] = {0.2*self.drawableWidth, 0.3 * self.drawableHeight};
        GLfloat leftBottomTangentVex[] = {-0.3 * self.drawableWidth, self.drawableHeight * 0.7};
        GLfloat rightTopTangentVex[] = {1.2 * self.drawableWidth, 0.3 * self.drawableHeight};
        GLfloat rightBottomTangentVex[] = {0.8 * self.drawableWidth, 0.8 * self.drawableHeight};
        
        GLuint topLeftVexSlot = glGetUniformLocation(self.program, "topLeftVex");
        GLuint topLeftTangentVexSlot = glGetUniformLocation(self.program, "topLeftTangentVex");
        GLuint topRightVexSlot = glGetUniformLocation(self.program, "topRightVex");
        GLuint topRightTangentVexSlot = glGetUniformLocation(self.program, "topRightTangentVex");
        GLuint bottomLeftVexSlot = glGetUniformLocation(self.program, "bottomLeftVex");
        GLuint bottomLeftTangentVexSlot = glGetUniformLocation(self.program, "bottomLeftTangentVex");
        GLuint bottomRightVexSlot = glGetUniformLocation(self.program, "bottomRightVex");
        GLuint bottomRightTangentVexSlot = glGetUniformLocation(self.program, "bottomRightTangentVex");
        
        GLuint leftTopTangentSlot = glGetUniformLocation(self.program, "leftTopTangentVex");
        GLuint leftBottomTangentSlot = glGetUniformLocation(self.program, "leftBottomTangentVex");
        GLuint rightTopTangentSlot = glGetUniformLocation(self.program, "rightTopTangentVex");
        GLuint rightBottomTangentSlot = glGetUniformLocation(self.program, "rightBottomTangentVex");
        
        glUniform2fv(topLeftVexSlot, 1, (GLfloat *)&topLeftVex[0]);
        glUniform2fv(topLeftTangentVexSlot, 1, (GLfloat *)&topLeftTangentVex[0]);
        glUniform2fv(topRightVexSlot, 1, (GLfloat *)&topRightVex[0]);
        glUniform2fv(topRightTangentVexSlot, 1, (GLfloat *)&topRightTangentVex[0]);
        glUniform2fv(bottomLeftVexSlot, 1, (GLfloat *)&bottomLeftVex[0]);
        glUniform2fv(bottomLeftTangentVexSlot, 1, (GLfloat *)&bottomLeftTangentVex[0]);
        glUniform2fv(bottomRightVexSlot, 1, (GLfloat *)&bottomRightVex[0]);
        glUniform2fv(bottomRightTangentVexSlot, 1, (GLfloat *)&bottomRightTangentVex[0]);
        
        glUniform2fv(leftTopTangentSlot, 1, (GLfloat *)&leftTopTangentVex[0]);
        glUniform2fv(leftBottomTangentSlot, 1, (GLfloat *)&leftBottomTangentVex[0]);
        glUniform2fv(rightTopTangentSlot, 1, (GLfloat *)&rightTopTangentVex[0]);
        glUniform2fv(rightBottomTangentSlot, 1, (GLfloat *)&rightBottomTangentVex[0]);
    }else if (self.currentIndex == 41){
        
    }
    
    // 重绘
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    //第二次绘制
    if(self.currentIndex == 10 || self.currentIndex == 11 || self.currentIndex == 14 || self.currentIndex == 23 || self.currentIndex == 24 || self.currentIndex == 25) {
        glUseProgram(self.program2);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        //第二次绘制将FBO绘制到平面上
        glBindFramebuffer(GL_FRAMEBUFFER, self.framebufferID);

        glClearColor(0.0, 0.0, 0.0, 0.0);

        GLuint positionSlot2 = glGetAttribLocation(self.program2, "position");
        GLuint textureCoordsSlot2 = glGetAttribLocation(self.program2,"inputTextureCoordinate");
        GLuint textureSlot2 = glGetUniformLocation(self.program2, "inputImageTexture");
        GLuint texture2Slot2 = glGetUniformLocation(self.program2, "inputImageTexture2");
        GLuint texture2Slot3 = glGetUniformLocation(self.program2, "inputImageTexture3");

        GLuint resolutionSlot2 = glGetUniformLocation(self.program2, "resolution");
        GLfloat resolution[] = {self.drawableWidth, self.drawableHeight};
        CGFloat currentTime2 = self.displayLink.timestamp - self.startTimeInterval;
        GLuint time2 = glGetUniformLocation(self.program2, "time");
        

                
        glUniform1f(time2, currentTime2);
        
        if (self.currentIndex == 24 || self.currentIndex == 25) {
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, self.texture2ID);
            glUniform1i(textureSlot2, 0);
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D, self.texture5ID);
            glUniform1i(texture2Slot2, 1);
        }else if (self.currentIndex == 23){
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, self.texture2ID);
            glUniform1i(textureSlot2, 0);
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D, self.texture3ID);
            glUniform1i(texture2Slot2, 1);
            
            glActiveTexture(GL_TEXTURE2);
            glBindTexture(GL_TEXTURE_2D, self.texture5ID);
            glUniform1i(texture2Slot3, 2);
        }


        
        glUniform2fv(resolutionSlot2, 1, (GLfloat *)&resolution[0]);
        glEnableVertexAttribArray(positionSlot2);
        glVertexAttribPointer(positionSlot2, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
        glEnableVertexAttribArray(textureCoordsSlot2);
        glVertexAttribPointer(textureCoordsSlot2, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - FilterBarDelegate
#define PI 3.1415926
- (void)filterBar:(FilterBar *)filterBar didScrollToIndex:(NSUInteger)index {
    
    if (self.currentIndex == index) {
        return;
    }
    
    [self.actions removeAllObjects];
    if (index == 0) {
        self.currentIndex = 0;
        [self setupNormalShaderProgram];
    } else if (index == 1) {
        self.currentIndex = 1;
        [self setupScaleShaderProgram];
        
    } else if (index == 2) {
        self.currentIndex = 2;
        [self setupSoulOutShaderProgram];
    } else if (index == 3) {
        self.currentIndex = 3;
        [self setupShakeShaderProgram];
    } else if (index == 4) {
        self.currentIndex = 4;
        [self setupShineWhiteShaderProgram];
        
    } else if (index == 5) {
        self.currentIndex = 5;
        [self setupGlitchShaderProgram];
    } else if (index == 6) {
        self.currentIndex = 6;
        [self setupVertigoShaderProgram];
    } else if (index == 7) {
        //transform解析参数
        Transform alphaT = {AlphaType, 0.f, 1.f, 1.f, 0.f};
        [self.actions addObject:[NSValue value: &alphaT withObjCType:@encode(Transform)]];
        
        Transform scaleT = {ScaleType, 0.f, 1.f, 1.f, 1.5f};
        [self.actions addObject:[NSValue value: &scaleT withObjCType:@encode(Transform)]];
        
        Transform rotateT = {RotateType, 0.f, 1.f, 0.f, 0.f};
        [self.actions addObject:[NSValue value: &rotateT withObjCType:@encode(Transform)]];
        
        Transform posT = {PosType, 0.f, 1.f, 0.f, 0.f};
        [self.actions addObject:[NSValue value: &posT withObjCType:@encode(Transform)]];
        
        Transform blurT = {BlurType, 0.f, 1.f, 0.f, 1.f};
        [self.actions addObject:[NSValue value: &blurT withObjCType:@encode(Transform)]];
        self.currentIndex = 7;
        [self setupEnlargeShaderProgram];
    } else if (index == 8) {
        //transform解析参数
        Transform alphaT = {AlphaType, 0.f, 0.2f, 0.f, 1.f};
        [self.actions addObject:[NSValue value: &alphaT withObjCType:@encode(Transform)]];
        
        Transform scaleT = {ScaleType, 0.f, 1.f, 0.f, 1.f};
        [self.actions addObject:[NSValue value: &scaleT withObjCType:@encode(Transform)]];
        
        Transform rotateT = {RotateType, 0.f, 1.f, -4.f * PI, 0.f};
        [self.actions addObject:[NSValue value: &rotateT withObjCType:@encode(Transform)]];
        
        Transform posT = {PosType, 0.f, 0.1f, 0.f, 0.f};
        [self.actions addObject:[NSValue value: &posT withObjCType:@encode(Transform)]];
        
        Transform blurT = {BlurType, 0.f, 1.f, 0.f, 1.f};
        [self.actions addObject:[NSValue value: &blurT withObjCType:@encode(Transform)]];
        
        self.currentIndex = 8;
        [self setupRotateShaderProgram];
    } else if (index == 9) {
        //transform解析参数
        Transform alphaT = {AlphaType, 0.f, 1.f, 1.f, 1.f};
        [self.actions addObject:[NSValue value: &alphaT withObjCType:@encode(Transform)]];
        
        Transform scaleT = {ScaleType, 0.f, 1.f, 1.f, 1.f};
        [self.actions addObject:[NSValue value: &scaleT withObjCType:@encode(Transform)]];
        
        Transform rotateT = {RotateType, 0.f, 0.5f, 0.f, 0.f};
        [self.actions addObject:[NSValue value: &rotateT withObjCType:@encode(Transform)]];

        Transform posT = {PosType, 0.f, 0.5f, -1.f, 0.f};
        [self.actions addObject:[NSValue value: &posT withObjCType:@encode(Transform)]];
        
        Transform blurT = {BlurType, 0.f, 0.5f, 0.f, 1.f};
        [self.actions addObject:[NSValue value: &blurT withObjCType:@encode(Transform)]];
        
        Transform rotateT2 = {RotateType, 0.5f, 1.f, 0.f, -0.5f*PI};
        [self.actions addObject:[NSValue value: &rotateT2 withObjCType:@encode(Transform)]];
        
        Transform blurT2 = {BlurType, 0.5f, 1.f, 1.f, 0.f};
        [self.actions addObject:[NSValue value: &blurT2 withObjCType:@encode(Transform)]];
        
        self.currentIndex = 9;
        [self setupDescendShaderProgram];
    }
    else if (index == 10) {
        self.currentIndex = 10;
        [self setupEdgeShaderProgram];
    }
    else if (index == 11) {
        self.currentIndex = 11;
        [self setupFluorescentShaderProgram];
    }
    else if (index == 12) {
        self.currentIndex = 12;
        [self setupCrossShaderProgram];
    }
    else if (index == 13) {
        self.currentIndex = 13;
        [self setupTyndallShaderProgram];
    }
    else if(index == 14) {
        self.currentIndex = 14;
        [self setupColorEdgeShaderProgram];
    }
    else if(index == 15) {
        self.currentIndex = 15;
        [self setupCameraFocusShaderProgram];
    }
    else if(index == 16) {
        self.currentIndex = 16;
        [self setupRainBowShaderProgram];
    }
    else if(index == 17) {
        self.currentIndex = 17;
        [self setupGaussianBlurShaderProgram];
    }
    else if(index == 18) {
        self.currentIndex = 18;
        [self setupDirectBlurShaderProgram];
    }
    else if(index == 19) {
        self.currentIndex = 19;
        [self setupRadialBlurShaderProgram];
    }
    else if(index == 20) {
        self.currentIndex = 20;
        [self setupSharpenShaderProgram];
    }
    else if(index == 21) {
        self.currentIndex = 21;
        [self setupCornerPinShaderProgram];
    }
    else if(index == 22) {
        self.currentIndex = 22;
        [self setupBezierShaderProgram];
    }
    else if(index == 23) {
        self.currentIndex = 23;
        [self setupGhostAndColorLineShaderProgram];
    }
    else if(index == 24) {
        self.currentIndex = 24;
        
        [self setupGhostAndRainBowShaderProgram];

    }
    else if(index == 25) {
        self.currentIndex = 25;
        
        [self setupGhostAndLineMoveShaderProgram];

    }
    
    
    // 重新开始计算时间
    [self startFilerAnimation];
}

#pragma mark - Shader

// 默认着色器程序
- (void)setupNormalShaderProgram {
    [self setupShaderProgramWithName:@"Normal"];
}

// 缩放着色器程序
- (void)setupScaleShaderProgram {
    [self setupShaderProgramWithName:@"Scale"];
}

// 灵魂出窍着色器程序
- (void)setupSoulOutShaderProgram {
    [self setupShaderProgramWithName:@"SoulOut"];
}

// 抖动着色器程序
- (void)setupShakeShaderProgram {
    [self setupShaderProgramWithName:@"Shake"];
}

// 闪白着色器程序
- (void)setupShineWhiteShaderProgram {
    [self setupShaderProgramWithName:@"ShineWhite"];
}

// 毛刺着色器程序
- (void)setupGlitchShaderProgram {
    [self setupShaderProgramWithName:@"Glitch"];
}

// 幻觉着色器程序
- (void)setupVertigoShaderProgram {
    [self setupShaderProgramWithName:@"Vertigo"];
}

// 放大着色器程序
- (void)setupEnlargeShaderProgram {
    [self setupRDShaderProgramWithName:@"Enlarge"];
}

// 旋转着色器程序
- (void)setupRotateShaderProgram {
    [self setupRDShaderProgramWithName:@"Rotate"];
}

// 下降着色器程序
- (void)setupDescendShaderProgram {
    [self setupRDShaderProgramWithName:@"Descend"];
}

// 边缘上色着色器程序
- (void)setupEdgeShaderProgram {
    [self setupRDShaderProgramWithName:@"EdgeFlash"];
}

// 边缘荧光着色器程序
- (void)setupFluorescentShaderProgram {
    [self setupRDShaderProgramWithName:@"Fluorescent"];
}

// 交错着色器程序
- (void)setupCrossShaderProgram {
    [self setupRDShaderProgramWithName:@"Cross"];
}

// 丁达尔着色器程序
- (void)setupTyndallShaderProgram {
    [self setupShaderProgramWithName:@"Tyndall"];
}

// 彩色线条着色器程序
- (void)setupColorEdgeShaderProgram {
    [self setupRDShaderProgramWithName:@"ColorEdgeSecond"];
}

// 相机焦点着色器程序
- (void)setupCameraFocusShaderProgram {
    [self setupRDShaderProgramWithName:@"CameraFocus"];
}

// 彩虹着色器程序
- (void)setupRainBowShaderProgram {
//    [self setupRDShaderProgramWithName:@"StarSky"];
    
    [self setupRDShaderProgramWithName:@"RainBow"];
    
    
//    [self setupRDShaderProgramWithName:@"JumpHeart"];

//    [self setupRDShaderProgramWithName:@"thunderstorm"];
    
//    [self setupRDShaderProgramWithName:@"rainbowRotate"];

//    [self setupRDShaderProgramWithName:@"fireworks"];

    
//    [self setupRDShaderProgramWithName:@"mask"];

    

}

// 高斯模糊着色器程序
- (void)setupGaussianBlurShaderProgram {
    [self setupRDShaderProgramWithName:@"GaussianBlur"];
}

// 定向模糊着色器程序
- (void)setupDirectBlurShaderProgram {
    [self setupRDShaderProgramWithName:@"DirectBlur"];
}

// 径向模糊着色器程序
- (void)setupRadialBlurShaderProgram {
    [self setupRDShaderProgramWithName:@"RadialBlur"];
}

// 锐化着色器程序
- (void)setupSharpenShaderProgram {
    [self setupRDShaderProgramWithName:@"Sharpen"];
}

// 边角着色器程序
- (void)setupCornerPinShaderProgram {
    [self setupRDShaderProgramWithName:@"CornerPin"];
}

// 贝塞尔着色器程序
- (void)setupBezierShaderProgram {
    [self setupRDShaderProgramWithName:@"Bezier"];
}

// 残影+彩色线条 ghostAndColorLine
- (void)setupGhostAndColorLineShaderProgram {
    [self setupGhostAndColorLineShaderProgramWithName];
}

// 残影+彩虹 ghostAndRainBow
- (void)setupGhostAndRainBowShaderProgram {
    [self setupGhostAndRainBowShaderProgramWithName];
}

// 残影+彩虹 ghostAndRainBow
- (void)setupGhostAndLineMoveShaderProgram {
    [self setupGhostAndLineMoveShaderProgramWithName];
}


// 初始化着色器程序
- (void)setupShaderProgramWithName:(NSString *)name {
    GLuint program = [self programWithShaderName:name];
    glUseProgram(program);
    
    GLuint positionSlot = glGetAttribLocation(program, "position");
    GLuint textureSlot = glGetUniformLocation(program, "inputImageTexture");
    GLuint textureCoordsSlot = glGetAttribLocation(program, "inputTextureCoordinate");
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    glUniform1i(textureSlot, 0);
    
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    
    glEnableVertexAttribArray(textureCoordsSlot);
    glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    
    self.program = program;
}

// 初始化RD着色器程序
- (void)setupRDShaderProgramWithName:(NSString *)name {
    
    if (self.currentIndex == 10 || self.currentIndex == 11 || self.currentIndex == 14 || self.currentIndex == 23) {
        GLfloat resolution[] = {self.drawableWidth, self.drawableHeight};
        GLfloat edgeColorv[] = {210.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0};
        if (self.currentIndex == 14) {
            edgeColorv[0] = 66.0 / 255.0;
            edgeColorv[1] = 15.0 / 255.0;
            edgeColorv[2] = 206.0 / 255.0;
        }
        GLuint program = [self programWithShaderName:@"Edge"];
        glUseProgram(program);
        GLuint positionSlot = glGetAttribLocation(program, "position");
        GLuint edgeColor = glGetUniformLocation(program, "edgeColor");
        GLuint textureSlot = glGetUniformLocation(program, "inputImageTexture");
        GLuint resolutionSlot = glGetUniformLocation(program, "resolution");
        GLuint textureCoordsSlot = glGetAttribLocation(program,"inputTextureCoordinate");
        CGFloat currentTime = self.displayLink.timestamp - self.startTimeInterval;
        GLuint time = glGetUniformLocation(program, "time");
        glUniform1f(time, currentTime);

        glActiveTexture(GL_TEXTURE0);
        if (self.currentIndex == 14) {
            glBindTexture(GL_TEXTURE_2D, self.texture3ID);
        } else {
            glBindTexture(GL_TEXTURE_2D, self.textureID);
        }
        glUniform1i(textureSlot, 0);
        glUniform3fv(edgeColor, 1, (GLfloat *)&edgeColorv[0]);
        glUniform2fv(resolutionSlot, 1, (GLfloat *)&resolution[0]);
        glEnableVertexAttribArray(positionSlot);
        glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
        glEnableVertexAttribArray(textureCoordsSlot);
        glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
        self.program = program;
        
        GLuint program2 = [self programWithShaderName:name];
        glUseProgram(program2);
        GLuint positionSlot2 = glGetAttribLocation(program2, "position");
        GLuint textureCoordsSlot2 = glGetAttribLocation(program2,"inputTextureCoordinate");
        GLuint textureSlot2 = glGetUniformLocation(program2, "inputImageTexture");
        GLuint texture2Slot2 = glGetUniformLocation(program2, "inputImageTexture2");
        GLuint resolutionSlot2 = glGetUniformLocation(program2, "resolution");
        CGFloat currentTime2 = self.displayLink.timestamp - self.startTimeInterval;
        GLuint time2 = glGetUniformLocation(program2, "time");
        glUniform1f(time2, currentTime2);
  
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, self.textureID);
        glUniform1i(textureSlot2, 0);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, self.texture2ID);
        glUniform1i(texture2Slot2, 1);
        glUniform2fv(resolutionSlot2, 1, (GLfloat *)&resolution[0]);
        glEnableVertexAttribArray(positionSlot2);
        glVertexAttribPointer(positionSlot2, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
        glEnableVertexAttribArray(textureCoordsSlot2);
        glVertexAttribPointer(textureCoordsSlot2, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
        self.program2 = program2;
        return;
    }
    if (self.currentIndex == 12 || self.currentIndex == 15 || self.currentIndex == 16) {
        GLfloat resolution[] = {self.drawableWidth, self.drawableHeight};
        GLuint program = [self programWithShaderName:name];
        glUseProgram(program);
        GLuint positionSlot = glGetAttribLocation(program, "position");
        GLuint textureCoordsSlot = glGetAttribLocation(program,"inputTextureCoordinate");
        GLuint textureSlot = glGetUniformLocation(program, "inputImageTexture");
        GLuint texture2Slot = glGetUniformLocation(program, "inputImageTexture2");
        
        
        if (self.isTextCode) {
//            GLuint texture3Slot = glGetUniformLocation(program, "maomaofilter");
//            GLuint texture4Slot = glGetUniformLocation(program, "biankuang");
//            glUniform1i(texture3Slot, 2);
//            glUniform1i(texture4Slot, 3);
//
//            GLuint transformSlot = glGetUniformLocation(program, "transform");
//            GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(0.0, 0.5, 0.0,1.0);
//            glUniformMatrix4fv(transformSlot, 1, GL_FALSE, rotateMatrix.m);
        }
        
        GLuint resolutionSlot = glGetUniformLocation(program, "resolution");
        
        if (self.currentIndex == 16) {
            
            GLuint maskTexture = [self createTextureWithImage:self.maskImage];
            self.texture3ID = maskTexture;
        }
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, self.textureID);
        glUniform1i(textureSlot, 0);
        glActiveTexture(GL_TEXTURE1);
        if(self.currentIndex == 15) {
            glBindTexture(GL_TEXTURE_2D, self.texture4ID);
        }else {
            glBindTexture(GL_TEXTURE_2D, self.texture3ID);
        }
        glUniform1i(texture2Slot, 1);

        glUniform2fv(resolutionSlot, 1, (GLfloat *)&resolution[0]);
        glEnableVertexAttribArray(positionSlot);
        glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
        glEnableVertexAttribArray(textureCoordsSlot);
        glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
        self.program = program;
        return;
    }
    GLuint program = [self programWithShaderName:name];
    glUseProgram(program);
        
    GLuint positionSlot = glGetAttribLocation(program, "position");
    GLuint transformSlot = glGetUniformLocation(program, "transform");
    GLuint translateSlot = glGetUniformLocation(program, "translate");
    GLuint scaleSlot = glGetUniformLocation(program, "scale");
    
    GLuint textureSlot = glGetUniformLocation(program, "inputImageTexture");
    GLuint srcMatrixSlot = glGetUniformLocation(program, "srcMatrix");
    GLuint alphaSlot = glGetUniformLocation(program, "alpha");
    GLuint blurStepSlot = glGetUniformLocation(program, "blurStep");
    GLuint blurDirectionSlot = glGetUniformLocation(program, "blurDirection");
    GLuint resolutionSlot = glGetUniformLocation(program, "resolution");
    GLuint textureCoordsSlot = glGetAttribLocation(program, "inputTextureCoordinate");
 
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    
    for (NSValue *item in self.actions){
        Transform t;
        [item getValue: &t];
        if (t.type == RotateType && t.start == 0.f) {
//            float s = sin(t.startFrom);
//            float c = cos(t.startFrom);
//            GLfloat T[] = {
//                c, -s, 0.f, 0.f,
//                s, c, 0.f, 0.f,
//                0.f, 0.f, 1.f, 0.f,
//                0.f, 0.f, 0.f, 1.f,
//            };
//           glUniformMatrix4fv(transformSlot, 1, GL_FALSE, (GLfloat *)&T);
            GLKMatrix4 mMatrix = GLKMatrix4Identity;
            GLKMatrix4 sMatrix = GLKMatrix4MakeScale(self.viewWidth/2, self.viewHeight/2, 1);
            GLKMatrix4 oMatrix = GLKMatrix4MakeOrtho(-self.viewWidth/2, self.viewWidth/2, -self.viewHeight/2, self.viewHeight/2, -1, 1);
            mMatrix = GLKMatrix4Multiply(sMatrix, mMatrix);
            GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(t.startFrom, 0.0, 0.0,
                                                             t.startFrom > 0.f ? 1.0 : -1.0);
            GLKMatrix4 transformMatrix = GLKMatrix4Multiply(rotateMatrix, mMatrix);
            transformMatrix = GLKMatrix4Multiply(oMatrix, transformMatrix);
            glUniformMatrix4fv(transformSlot, 1, GL_FALSE, transformMatrix.m);
        }
        else if (t.type == ScaleType && t.start == 0.f) {
            glUniform1f(scaleSlot, t.startFrom);
        }
        else if (t.type == PosType && t.start == 0.f) {
            GLfloat translate[] = {0.f, t.startFrom};
            glUniform2fv(translateSlot, 1, (GLfloat *)&translate[0]);
        }
        else if (t.type == AlphaType && t.start == 0.f) {
            glUniform1f(alphaSlot, t.startFrom);
        }
        else if (t.type == BlurType && t.start == 0.f) {
            GLfloat blurDirection[] = {1.f, 0.f};
            glUniform2fv(blurDirectionSlot, 1, (GLfloat *)&blurDirection[0]);
            glUniform1f(blurStepSlot, t.startFrom);
        }
    }
    if( self.currentIndex == 17 ){
        GLuint horizontalSlot = glGetUniformLocation(program, "horizontal");
        GLuint levelSlot = glGetUniformLocation(program, "level");
        glUniform1i(horizontalSlot, false);
        glUniform1f(levelSlot, 500.0);
    } else if ( self.currentIndex == 18 ) {
        GLuint angleSlot = glGetUniformLocation(program, "angle");
        GLuint blurSlot = glGetUniformLocation(program, "blurStep");
        glUniform1f(angleSlot, 60);
        glUniform1f(blurSlot, 1.0);
    }
    
    glUniform1i(textureSlot, 0);
    GLfloat srcMatrix[] = {
        1.f, 0.f, 0.f, 0.f,
        0.f, 1.f, 0.f, 0.f,
        0.f, 0.f, 1.f, 0.f,
        0.f, 0.f, 0.f, 1.f,
    };
    glUniformMatrix4fv(srcMatrixSlot, 1, GL_FALSE, (GLfloat *)&srcMatrix);
    
    GLfloat resolution[] = {self.drawableWidth, self.drawableHeight};
    glUniform2fv(resolutionSlot, 1, (GLfloat *)&resolution[0]);
    
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    
    glEnableVertexAttribArray(textureCoordsSlot);
    glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    
    
    self.program = program;
}

- (void)setupGhostAndColorLineShaderProgramWithName{
        GLfloat resolution[] = {self.drawableWidth, self.drawableHeight};
        GLfloat edgeColorv[] = {210.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0};
//        if (self.currentIndex == 14) {
            edgeColorv[0] = 66.0 / 255.0;
            edgeColorv[1] = 15.0 / 255.0;
            edgeColorv[2] = 206.0 / 255.0;
//        }
    GLuint program = [self programWithShaderName:@"Edge"];
    glUseProgram(program);
    GLuint positionSlot = glGetAttribLocation(program, "position");
    GLuint edgeColor = glGetUniformLocation(program, "edgeColor");
    GLuint texture1Slot = glGetUniformLocation(program, "inputImageTexture");

    GLuint resolutionSlot = glGetUniformLocation(program, "resolution");
    GLuint textureCoordsSlot = glGetAttribLocation(program,"inputTextureCoordinate");
    CGFloat currentTime = self.displayLink.timestamp - self.startTimeInterval;
    GLuint time = glGetUniformLocation(program, "time");
    glUniform1f(time, currentTime);

        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, self.textureID);

        glUniform1i(texture1Slot, 0);
    
    
        glUniform3fv(edgeColor, 1, (GLfloat *)&edgeColorv[0]);
        glUniform2fv(resolutionSlot, 1, (GLfloat *)&resolution[0]);
        glEnableVertexAttribArray(positionSlot);
        glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
        glEnableVertexAttribArray(textureCoordsSlot);
        glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
        self.program = program;
        
        GLuint program2 = [self programWithShaderName:@"ColorEdge"];
        glUseProgram(program2);
        GLuint positionSlot2 = glGetAttribLocation(program2, "position");
        GLuint textureCoordsSlot2 = glGetAttribLocation(program2,"inputTextureCoordinate");
        GLuint textureSlot2 = glGetUniformLocation(program2, "inputImageTexture");
        GLuint texture2Slot2 = glGetUniformLocation(program2, "inputImageTexture2");
        GLuint texture2Slot3 = glGetUniformLocation(program2, "inputImageTexture3");
        GLuint resolutionSlot2 = glGetUniformLocation(program2, "resolution");
        CGFloat currentTime2 = self.displayLink.timestamp - self.startTimeInterval;
        GLuint time2 = glGetUniformLocation(program2, "time");
        glUniform1f(time2, currentTime2);
  
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, self.texture2ID);
        glUniform1i(textureSlot2, 0);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, self.texture3ID);
        glUniform1i(texture2Slot2, 1);
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, self.texture5ID);
    glUniform1i(texture2Slot3, 2);
        glUniform2fv(resolutionSlot2, 1, (GLfloat *)&resolution[0]);
        glEnableVertexAttribArray(positionSlot2);
        glVertexAttribPointer(positionSlot2, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
        glEnableVertexAttribArray(textureCoordsSlot2);
        glVertexAttribPointer(textureCoordsSlot2, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
        self.program2 = program2;
//        return;
}


- (void)setupGhostAndRainBowShaderProgramWithName{
    GLfloat resolution[] = {self.drawableWidth, self.drawableHeight};

    GLuint program = [self programWithShaderName:@"RainBow"];
    glUseProgram(program);
    GLuint positionSlot = glGetAttribLocation(program, "position");
    GLuint texture1Slot = glGetUniformLocation(program, "inputImageTexture");
    GLuint texture2Slot = glGetUniformLocation(program, "inputImageTexture2");

    GLuint resolutionSlot = glGetUniformLocation(program, "resolution");
    GLuint textureCoordsSlot = glGetAttribLocation(program,"inputTextureCoordinate");
    CGFloat currentTime = self.displayLink.timestamp - self.startTimeInterval;
    GLuint time = glGetUniformLocation(program, "time");
    glUniform1f(time, currentTime);

    //原图
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    glUniform1i(texture1Slot, 0);

    //抠像图一
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.texture3ID);
    glUniform1i(texture2Slot, 1);

    glUniform2fv(resolutionSlot, 1, (GLfloat *)&resolution[0]);
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    glEnableVertexAttribArray(textureCoordsSlot);
    glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    self.program = program;
    
    GLuint program2 = [self programWithShaderName:@"RainBowSecond"];
    glUseProgram(program2);
    GLuint positionSlot2 = glGetAttribLocation(program2, "position");
    GLuint textureCoordsSlot2 = glGetAttribLocation(program2,"inputTextureCoordinate");
    GLuint textureSlot2 = glGetUniformLocation(program2, "inputImageTexture");
    GLuint texture2Slot2 = glGetUniformLocation(program2, "inputImageTexture2");
    GLuint resolutionSlot2 = glGetUniformLocation(program2, "resolution");
    CGFloat currentTime2 = self.displayLink.timestamp - self.startTimeInterval;
    GLuint time2 = glGetUniformLocation(program2, "time");
    glUniform1f(time2, currentTime2);

    //fbo图
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture2ID);
    glUniform1i(textureSlot2, 0);
    
    //抠像图二
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.texture5ID);
    glUniform1i(texture2Slot2, 1);
    glUniform2fv(resolutionSlot2, 1, (GLfloat *)&resolution[0]);
    glEnableVertexAttribArray(positionSlot2);
    glVertexAttribPointer(positionSlot2, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    glEnableVertexAttribArray(textureCoordsSlot2);
    glVertexAttribPointer(textureCoordsSlot2, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    self.program2 = program2;
//        return;
}

- (void)setupGhostAndLineMoveShaderProgramWithName{
    GLfloat resolution[] = {self.drawableWidth, self.drawableHeight};

    GLuint program = [self programWithShaderName:@"LineDisplacement"];
    glUseProgram(program);
    GLuint positionSlot = glGetAttribLocation(program, "position");
    GLuint texture1Slot = glGetUniformLocation(program, "inputImageTexture");
    GLuint texture2Slot = glGetUniformLocation(program, "inputImageTexture2");

    GLuint resolutionSlot = glGetUniformLocation(program, "resolution");
    GLuint textureCoordsSlot = glGetAttribLocation(program,"inputTextureCoordinate");
    CGFloat currentTime = self.displayLink.timestamp - self.startTimeInterval;
    GLuint time = glGetUniformLocation(program, "time");
    glUniform1f(time, currentTime);

    //原图
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    glUniform1i(texture1Slot, 0);

    //抠像图一
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.texture3ID);
    glUniform1i(texture2Slot, 1);

    glUniform2fv(resolutionSlot, 1, (GLfloat *)&resolution[0]);
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    glEnableVertexAttribArray(textureCoordsSlot);
    glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    self.program = program;
    
    GLuint program2 = [self programWithShaderName:@"LineDisplacement"];
    glUseProgram(program2);
    GLuint positionSlot2 = glGetAttribLocation(program2, "position");
    GLuint textureCoordsSlot2 = glGetAttribLocation(program2,"inputTextureCoordinate");
    GLuint textureSlot2 = glGetUniformLocation(program2, "inputImageTexture");
    GLuint texture2Slot2 = glGetUniformLocation(program2, "inputImageTexture2");
    GLuint resolutionSlot2 = glGetUniformLocation(program2, "resolution");
    CGFloat currentTime2 = self.displayLink.timestamp - self.startTimeInterval;
    GLuint time2 = glGetUniformLocation(program2, "time");
    glUniform1f(time2, currentTime2);

    //fbo图
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture2ID);
    glUniform1i(textureSlot2, 0);
    
    //抠像图二
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.texture5ID);
    glUniform1i(texture2Slot2, 1);
    glUniform2fv(resolutionSlot2, 1, (GLfloat *)&resolution[0]);
    glEnableVertexAttribArray(positionSlot2);
    glVertexAttribPointer(positionSlot2, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    glEnableVertexAttribArray(textureCoordsSlot2);
    glVertexAttribPointer(textureCoordsSlot2, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    self.program2 = program2;
}

@end
