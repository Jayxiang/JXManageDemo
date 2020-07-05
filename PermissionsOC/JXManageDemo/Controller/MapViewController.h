//
//  MapViewController.h
//  CJXDemo
//
//  Created by tet-cjx on 2017/7/7.
//  Copyright © 2017年 hyd-cjx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController

//纬度
@property (nonatomic, assign) double latitude;
//经度
@property (nonatomic, assign)  double longitude;
@property (nonatomic, strong) NSString *city;
@end
