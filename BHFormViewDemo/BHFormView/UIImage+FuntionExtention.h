//
//  UIImage+FuntionExtention.h
//  BHFormViewDemo
//
//  Created by 熊伟 on 2016/5/16.
//  Copyright © 2016年 熊伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FuntionExtention)
- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size;
- (BOOL)hasAlpha;
- (UIImage *)imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;
+ (UIImage *)imageFromColor:(UIColor *)color;
@end
