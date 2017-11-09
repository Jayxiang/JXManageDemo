//
//  CLLocation+Sino.h
//  CJXDemo
//
//  Created by tet-cjx on 2017/7/7.
//  Copyright © 2017年 hyd-cjx. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (Sino)

/**地球坐标转火星坐标*/
- (CLLocation*)locationMarsFromEarth;

/**火星坐标转百度坐标*/
- (CLLocation*)locationBearPawFromMars;

/**百度坐标转火星坐标*/
- (CLLocation*)locationMarsFromBearPaw;

@end
