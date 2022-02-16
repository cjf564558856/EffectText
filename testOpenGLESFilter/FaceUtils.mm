//
//  FaceUtils.m
//  testOpenGLESFilter
//
//  Created by IGG on 2021/11/5.
//  Copyright © 2021 Lyman Li. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/calib3d.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/core/types.hpp>
#import <opencv2/imgproc/types_c.h>


#import "FaceUtils.h"

using namespace std;
using namespace cv;

@implementation FaceUtils


+(UIImage*)faceDetectWithImage:(UIImage*)inputImage {
    
    
    
//    imread(const String &filename) 读取图像
//    imshow(const String &winname, InputArray mat)  显示图像
//    imwrite(const String &filename, InputArray img)  保存图像
//    cvtColor(InputArray src, OutputArray dst, int code)  色彩空间转换，比如转灰度和彩色
//    inRange(InputArray src, InputArray lowerb, InputArray upperb, OutputArray dst)  提取范围，用于绿幕抠像
    
    
    
    Mat image, image_gray;      //定义两个Mat变量，用于存储每一帧的图像
    UIImageToMat(inputImage, image);
    
    
//    image.zeros(int rows, int cols, int type) //创建空白图像
//    image.clone() 克隆，深拷贝
    
    //位操作
//    bitwise_or(InputArray src1, InputArray src2, OutputArray dst)
//    bitwise_and(InputArray src1, InputArray src2, OutputArray dst)
//    bitwise_not(InputArray src, OutputArray dst)
//    bitwise_xor(InputArray src1, InputArray src2, OutputArray dst)
    
//    split(const Mat &src, Mat *mvbegin) 通道分离
//    merge(InputArrayOfArrays mv, OutputArray dst)  通道合并
    
//    mixChannels(const Mat *src, size_t nsrcs, Mat *dst, size_t ndsts, const int *fromTo, size_t npairs) // 混合
    
    //像素值统计
//    minMaxLoc(const SparseMat &a, double *minVal, double *maxVal)  求最大值和最小值
//    meanStdDev(InputArray src, OutputArray mean, OutputArray stddev)  求平均值和标准方差
//    addWeighted(InputArray src1, double alpha, InputArray src2, double beta, double gamma, OutputArray dst)  求两个数组的加权和
    
    
    //几何图形绘制
//    rectangle(InputOutputArray img, Rect rec, const Scalar &color)
//    circle(InputOutputArray img, Point center, int radius, const Scalar &color)
//    line(InputOutputArray img, Point pt1, Point pt2, const Scalar &color)
//    ellipse(InputOutputArray img, Point center, Size axes, double angle, double startAngle, double endAngle, const Scalar &color) //绘制椭圆
//    polylines(InputOutputArray img, InputArrayOfArrays pts, bool isClosed, const Scalar &color) //绘制多边形
//    fillPoly(InputOutputArray img, const Point **pts, const int *npts, int ncontours, const Scalar &color) //填充多边形
//    drawContours(InputOutputArray image, InputArrayOfArrays contours, int contourIdx, const Scalar &color) //根据contours绘制多边形和填充
    
//    RNG()  随机数
    
    //像素类型转换与归一化
//    image.convertTo(OutputArray m, int rtype)
//    normalize(const Vec<_Tp, cn> &v)
    
//    resize(InputArray src, OutputArray dst, Size dsize) //重设大小
    
//    flip(InputArray src, OutputArray dst, int flipCode) //图像翻转
    
//    warpAffine(InputArray src, OutputArray dst, InputArray M, Size dsize)  //图像旋转
    
    //摄像头读取视频
    VideoCapture capture(0);
    
//    capture.get(CAP_PROP_FPS); 获取fps
//    capture.get(CAP_PROP_FRAME_COUNT); 获取帧数

//    capture.get(CAP_PROP_FRAME_WIDTH); 获取帧信息
//    Mat frame;
//    capture.read(frame);
//    capture.release();
    
    //保存视频，不能处理音频，一个视频文件不能超过2G
//    VideoWriter writer("",capture.get(CAP_PROP_FOCUS),fps,size,true);
    
    //计算直方图
//    calcHist(const Mat *images, int nimages, const int *channels, InputArray mask, OutputArray hist, int dims, const int *histSize, const float **ranges)
//    normalize(<#const SparseMat &src#>, <#SparseMat &dst#>, <#double alpha#>, <#int normType#>) //归一化直方图
    
//    blur(InputArray src, OutputArray dst, Size ksize)  卷积核
    
    
    cvtColor(image, image_gray, CV_BGR2GRAY);//转为灰度图
    equalizeHist(image_gray, image_gray);//直方图均衡化，增加对比度方便处理
    
    CascadeClassifier eye_Classifier;  //载入分类器
    CascadeClassifier face_cascade;    //载入分类器
    
    //加载分类训练器，OpenCv官方文档提供的xml文档，可以直接调用
    //xml文档路径  opencv\sources\data\haarcascades
    NSString *eyeName = @"haarcascade_eye";
    NSString *eyePath = [[NSBundle mainBundle]pathForResource:eyeName ofType:@"xml"];
    String path1 = eyePath.UTF8String;
    if (!eye_Classifier.load(path1))  //需要将xml文档放在自己指定的路径下
    {
        cout << "Load haarcascade_eye.xml failed!" << endl;
        return 0;
    }
    
    NSString *frontFaceName = @"haarcascade_frontalface_default";
    NSString *frontFacePath = [[NSBundle mainBundle]pathForResource:frontFaceName ofType:@"xml"];
    String path2 = frontFacePath.UTF8String;
    if (!face_cascade.load(path2))
    {
        cout << "Load haarcascade_frontalface_alt failed!" << endl;
        return 0;
    }
    
    //vector 是个类模板 需要提供明确的模板实参 vector<Rect>则是个确定的类 模板的实例化
    vector<Rect2i> eyeRect;
    vector<Rect2i> faceRect;
    
    //检测关于眼睛部位位置
    eye_Classifier.detectMultiScale(image_gray, eyeRect, 1.1, 2, 0 | CASCADE_SCALE_IMAGE, Size2i(30, 30));
    for (size_t eyeIdx = 0; eyeIdx < eyeRect.size(); eyeIdx++)
    {
        rectangle(image, eyeRect[eyeIdx], Scalar(0, 0, 255), 5);   //用矩形画出检测到的位置
    }
    
    //检测关于脸部位置
    face_cascade.detectMultiScale(image_gray, faceRect, 1.1, 2, 0 | CASCADE_SCALE_IMAGE, Size2i(30, 30));
    for (size_t i = 0; i < faceRect.size(); i++)
    {
        rectangle(image, faceRect[i], Scalar(0, 0, 255), 5);      //用矩形画出检测到的位置
    }
    
    
    
    UIImage *result = MatToUIImage(image);
    return result;
}


@end
