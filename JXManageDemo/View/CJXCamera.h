//
//  CJXCamera.h
//  CJXDemo
//
//  Created by tet-cjx on 2017/7/10.
//  Copyright © 2017年 hyd-cjx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJXCamera : UIView

- (instancetype)initWithFrame:(CGRect)frame block:(void(^)(UIImage *image))block;

@end
