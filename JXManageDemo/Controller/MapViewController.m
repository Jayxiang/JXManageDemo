//
//  MapViewController.m
//  CJXDemo
//
//  Created by tet-cjx on 2017/7/7.
//  Copyright © 2017年 hyd-cjx. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "UIView+Sizes.h"
#define UIScreenWidth [[UIScreen mainScreen] bounds].size.width
#define UIScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface MapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UITableView *searchTable;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIActivityIndicatorView *load;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end

@implementation MapViewController {
    CLLocationManager *locationManager;
    CLLocation *location;
    CLLocationCoordinate2D coordinate;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self creatMapView];
    [self.view addSubview:_mapView];
    _backBtn.layer.cornerRadius = 10;
    [self.view bringSubviewToFront:_backBtn];
    [self.view addSubview:self.searchTable];
    [self getUserLocation];
    coordinate = CLLocationCoordinate2DMake(_latitude, _longitude);
    self.dataArr = [NSMutableArray arrayWithObjects:@"个人收藏", nil];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (UITableView *)searchTable {
    if (!_searchTable) {
        _searchTable = [[UITableView alloc] initWithFrame:CGRectMake(0,  UIScreenHeight - 64, UIScreenWidth, UIScreenHeight - 64) style:UITableViewStylePlain];
        _searchTable.delegate = self;
        _searchTable.dataSource = self;
        _searchTable.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:0.8].CGColor;
        _searchTable.layer.borderWidth = 1;
        _searchTable.layer.cornerRadius = 10;
        //        _searchTable.layer.masksToBounds = YES;
        //        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_searchTable.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(10,10)];
        //        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        //        maskLayer.frame = _searchTable.bounds;
        //        maskLayer.path = maskPath.CGPath;
        //        _searchTable.layer.mask = maskLayer;
        _searchTable.layer.shouldRasterize = YES;
        _searchTable.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //添加阴影
        //        _searchTable.clipsToBounds = NO;
        //        _searchTable.layer.shadowOffset = CGSizeMake(0, -2);
        //        _searchTable.layer.shadowColor = [UIColor grayColor].CGColor;
        //        _searchTable.layer.shadowRadius = 4;
        //        _searchTable.layer.shadowOpacity = 0.8;
        _searchTable.backgroundColor = [UIColor whiteColor];
        _searchTable.tableHeaderView = [UIView new];
        //        _searchTable.tableFooterView = [UIView new];
    }
    return _searchTable;
}
#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchCell"];
    }
    cell.textLabel.text = self.dataArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    UIView *line = [[UIView alloc] init];
    line.frame = CGRectMake((UIScreenWidth-30)/2, 5, 30, 5);
    line.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    line.layer.cornerRadius = 2;
    [view addSubview:line];
    view.backgroundColor = [UIColor whiteColor];
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.delegate = self;
    searchBar.frame = CGRectMake(10, 10, UIScreenWidth - 20, 54);
    searchBar.placeholder = @"搜索地点或地址";
    [view addSubview:searchBar];
    _searchBar = searchBar;
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 63, UIScreenWidth, 0.5)];
    bottomLine.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
    [view addSubview:bottomLine];
    return view;
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    if (_searchTable.y != 64) {
        [UIView animateWithDuration:0.3 animations:^{
            _searchTable.y = 64;
        } completion:^(BOOL finished) {
            
        }];
    }
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    // 如果希望在点击取消按钮调用结束编辑方法需要让加上这句代码
    [searchBar resignFirstResponder];
    if (_searchTable.y == 64) {
        [UIView animateWithDuration:0.3 animations:^{
            _searchTable.y = (UIScreenHeight - 64);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self getAroundInfoMationWithCoordinate:coordinate];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGPoint v = [scrollView.panGestureRecognizer velocityInView:scrollView];
    NSLog(@"%@",NSStringFromCGPoint(v));
}
// 滚动时调用此方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%f----%f", scrollView.contentOffset.y,_searchTable.y);
    [self.view endEditing:YES];
    [_searchBar setShowsCancelButton:NO animated:YES];
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (contentOffsetY > 0 && _searchTable.y <= UIScreenHeight - 64 && _searchTable.y >= 64) {
        if (_searchTable.y < 64) {
            _searchTable.y = 64;
            return;
        }
        if ((_searchTable.y - contentOffsetY) >= 74) {
            _searchTable.y -= contentOffsetY;
        }
    }
    if (contentOffsetY < 0 && _searchTable.y >= 64 && _searchTable.y <= UIScreenHeight - 64) {
        _searchTable.y -= contentOffsetY;
        if (_searchTable.y > UIScreenHeight - 64) {
            _searchTable.y = UIScreenHeight - 64;
        }
    }
}
// 完成拖拽(滚动停止时调用此方法，手指离开屏幕前)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_searchTable.y < (UIScreenHeight - 64) && _searchTable.y >= UIScreenHeight - (UIScreenHeight / 2)) {
        if (_searchTable.y > UIScreenHeight - (UIScreenHeight / 3 / 2 + 30)) {
            [UIView animateWithDuration:0.3 animations:^{
                _searchTable.y = (UIScreenHeight - 64);
            } completion:^(BOOL finished) {
                
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                _searchTable.y = UIScreenHeight - (UIScreenHeight / 3);
            } completion:^(BOOL finished) {
                
            }];
        }
        
    } else if (_searchTable.y < UIScreenHeight - (UIScreenHeight / 2)) {
        [UIView animateWithDuration:0.3 animations:^{
            _searchTable.y = 64;
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - 地图部分
- (void)creatMapView {
    _mapView =[[MKMapView alloc]initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight)];
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
- (void)getAroundInfoMationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 50, 50);
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]init];
    request.region = region;
    request.naturalLanguageQuery = _searchBar.text;
    MKLocalSearch *localSearch = [[MKLocalSearch alloc]initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        if (!error) {
            [self getAroundInfomation:response.mapItems];
        } else {
            NSLog(@"Quest around Error:%@",error.localizedDescription);
        }
    }];
}
-(void)getAroundInfomation:(NSArray *)array {
    for (MKMapItem *item in array) {
        MKPlacemark * placemark = item.placemark;
        [_dataArr addObject:placemark.name];
    }
    [_load stopAnimating];
    [self.searchTable reloadData];
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


@end

