//
//  FaceUtils.h
//  testOpenGLESFilter
//
//  Created by IGG on 2021/11/5.
//  Copyright © 2021 Lyman Li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FaceUtils : NSObject

+(UIImage*)faceDetectWithImage:(UIImage*)inputImage;

@end

NS_ASSUME_NONNULL_END
