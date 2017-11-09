//
//  MapViewController.m
//  CJXDemo
//
//  Created by tet-cjx on 2017/7/7.
//  Copyright © 2017年 hyd-cjx. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#define UIScreenWidth [[UIScreen mainScreen] bounds].size.width
#define UIScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface MapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) MKMapView *mapView;


@end

@implementation MapViewController {
    CLLocationManager *locationManager;
    CLLocation *location;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _mapView =[[MKMapView alloc]initWithFrame:CGRectMake(0, 64, UIScreenWidth, UIScreenHeight - 64)];
    // 设置地图显示样式(必须注意,设置时 注意对应的版本)
    self.mapView.mapType = MKMapTypeStandard;
    // 设置地图的控制项
    // 是否可以滚动
    //    self.mapView.scrollEnabled = NO;
    // 缩放
    //    self.mapView.zoomEnabled = NO;
    // 旋转
    //    self.mapView.rotateEnabled = NO;
    
    // 设置地图的显示项(注意::版本适配)
    // 显示建筑物
    self.mapView.showsBuildings = YES;
    // 指南针
    self.mapView.showsCompass = YES;
    // 兴趣点
    self.mapView.showsPointsOfInterest = YES;
    // 比例尺
    self.mapView.showsScale = YES;
    // 交通
    self.mapView.showsTraffic = YES;
    
    // 显示用户位置, 但是地图并不会自动放大到合适比例
    self.mapView.showsUserLocation = YES;
    
    /**
     *  MKUserTrackingModeNone = 0, 不追踪
     MKUserTrackingModeFollow,  追踪
     MKUserTrackingModeFollowWithHeading, 带方向的追踪
     */
    // 不但显示用户位置, 而且还会自动放大地图到合适的比例(也要进行定位授权)
    //    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    [self getUserLocation];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}
//获取当前位置
- (void)getUserLocation {
    CLLocationCoordinate2D theCoordinate;
    //位置更新后的经纬度
    theCoordinate.latitude = _latitude;
    theCoordinate.longitude = _longitude;
    //设定显示范围
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta=0.01;
    theSpan.longitudeDelta=0.01;
    //设置地图显示的中心及范围
    MKCoordinateRegion theRegion;
    theRegion.center=theCoordinate;
    theRegion.span=theSpan;
    [_mapView setRegion:theRegion];
    // 设置地图显示的类型及根据范围进行显示  安放大头针
    MKPointAnnotation *pinAnnotation = [[MKPointAnnotation alloc] init];
    pinAnnotation.coordinate = theCoordinate;
    pinAnnotation.title = _city;
    pinAnnotation.subtitle = @"测试";
    [_mapView addAnnotation:pinAnnotation];
}

// 每次添加大头针都会调用此方法  可以设置大头针的样式
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // 判断大头针位置是否在原点,如果是则不加大头针
    if([annotation isKindOfClass:[mapView.userLocation class]]) {
        return nil;
    }
    static NSString *annotationName = @"annotation";
    //自定义大头针
    MKAnnotationView *anView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationName];
    if(anView == nil)
    {
        anView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationName];
    }
    anView.image = [UIImage imageNamed:@"icecream-11"];
    //anView.pinTintColor = [UIColor blackColor];//设置大头针的颜色
    //anView.animatesDrop = YES;//设置从天而降的效果
    anView.canShowCallout = YES;//在点击大头针时是否显示标题
    // 设置大头针视图可以被拖拽
    //anView.draggable = YES;
    //anView.leftCalloutAccessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"uget"]];//设置大头针的左侧辅助视图
    //    anView.leftCalloutAccessoryView   可以设置左视图
    //    anView.rightCalloutAccessoryView   可以设置右视图
    return anView;
}
/**
 *  当地图获取到用户位置时调用
 *
 *  @param mapView      地图
 *  @param userLocation 大头针数据模型
 */
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    /**
     *  MKUserLocation : 专业术语: 大头针模型 其实喊什么都行, 只不过这个类遵循了大头针数据模型必须遵循的一个协议 MKAnnotation
     // title : 标注的标题
     // subtitle : 标注的子标题
     */
    userLocation.title = @"标题";
    userLocation.subtitle = @"子标题";
    
    // 移动地图的中心,显示用户的当前位置
    //    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    
    // 显示地图的显示区域
    // 控制区域中心
    CLLocationCoordinate2D center = userLocation.location.coordinate;
    // 设置区域跨度越小越详细
    MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
    
    // 创建一个区域
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    // 设置地图显示区域
    [mapView setRegion:region animated:YES];
}
//长按添加大头针事件
- (void)lpgrClick:(UILongPressGestureRecognizer *)lpgr {
    // 判断只在长按的起始点下落大头针
    if(lpgr.state == UIGestureRecognizerStateBegan)
    {
        // 首先获取点
        CGPoint point = [lpgr locationInView:_mapView];
        // 将一个点转化为经纬度坐标
        CLLocationCoordinate2D center = [_mapView convertPoint:point toCoordinateFromView:_mapView];
        MKPointAnnotation *pinAnnotation = [[MKPointAnnotation alloc] init];
        pinAnnotation.coordinate = center;
        pinAnnotation.title = @"长按";
        [_mapView addAnnotation:pinAnnotation];
    }
}
/**
 *  选中大头针视图时调用这个方法
 *
 *  @param mapView 地图
 *  @param view    大头针视图
 */
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"选中---%@", view.annotation.title);
}

/**
 *  取消选中某个大头针视图
 *
 *  @param mapView 地图
 *  @param view    大头针视图
 */
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"取消选中--%@", view.annotation.title);
}


/**
 *  改变大头针视图拖拽状态时调用
 *
 *  @param mapView  地图
 *  @param view     大头针视图
 *  @param newState 新状态
 *  @param oldState 老状态
 */
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    NSLog(@"%zd---%zd", oldState, newState);
}

//计算两个位置之间的距离
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
    //北京 (116.3,39.9)
    CLLocation *location1=[[CLLocation alloc]initWithLatitude:39.9 longitude:116.3];
    //郑州 (113.42,34.44)
    CLLocation *location2=[[CLLocation alloc]initWithLatitude:34.44 longitude:113.42];
    //比较北京距离郑州的距离
    CLLocationDistance locationDistance=[location1 distanceFromLocation:location2];
    //单位是m/s 所以这里需要除以1000
    NSLog(@"北京距离郑州的距离为:%f",locationDistance/1000);
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
