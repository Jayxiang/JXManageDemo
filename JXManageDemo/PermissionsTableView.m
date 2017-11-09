//
//  PermissionsTableView.m
//  CJXDemo
//
//  Created by tet-cjx on 2017/6/30.
//  Copyright © 2017年 hyd-cjx. All rights reserved.
//

#import "PermissionsTableView.h"
#import "CJXPermissionsManage.h"
#import <WebKit/WebKit.h>
#import <ContactsUI/ContactsUI.h>
#import <CoreLocation/CoreLocation.h>
#import "AudioRecorderViewController.h"
#import "PhoneticRecognitionVC.h"
#import "MapViewController.h"
#import "CLLocation+Sino.h"
#import "CJXCamera.h"
#import "JXQRController.h"
#define UIScreenWidth [[UIScreen mainScreen] bounds].size.width
#define UIScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface PermissionsTableView ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CNContactPickerDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) NSMutableArray *cameraArr;
@property (nonatomic, strong) NSMutableArray *photoArr;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation PermissionsTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [self registerNotifications];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.navigationItem.title = @"权限选择";
    
    self.photoArr = [NSMutableArray array];
    self.cameraArr = [NSMutableArray array];
    self.dataArr = @[@"相册",
                     @"网络",
                     @"相机",
                     @"通讯录",
                     @"一直请求定位权限",
                     @"使用时请求定位权限",
                     @"麦克风",
                     @"语音识别",
                     @"本地推送"];
    [CJXPermissionsManage sharedInstance].autoPresent = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"permissionscell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"permissionscell"];
    }
    if (indexPath.row == 0) {
        cell.imageView.image = self.photoArr.firstObject;
    } else if (indexPath.row == 2) {
        cell.imageView.image = self.cameraArr.firstObject;
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self     action:@selector(tapAction)];
        [cell.imageView addGestureRecognizer:tap];
        cell.imageView.userInteractionEnabled = YES;
    } else if (indexPath.row == 3) {
        cell.detailTextLabel.text = self.address;
    } else if (indexPath.row == 4) {
        cell.detailTextLabel.text = self.city;
    } else if (indexPath.row == 5) {
        cell.detailTextLabel.text = self.city;
    }
    cell.textLabel.text = self.dataArr[indexPath.row];
    return cell;
}
- (void)tapAction {
#if 0
    //方式1:保存图片到系统相册 注意:在保存之前需要获取相册权限
    UIImageWriteToSavedPhotosAlbum( self.cameraArr.firstObject, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
#endif
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //2:保存图片到系统相册
        [PHAssetChangeRequest creationRequestForAssetFromImage:self.cameraArr.firstObject];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (!success) return ;
        NSLog(@"保存成功");
    }];
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存失败");
    } else {
        NSLog(@"保存成功");
    }
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            [[CJXPermissionsManage sharedInstance] getPhotoPermissions:^(BOOL authorized) {
                if (authorized) {
                    NSLog(@"获得%@权限",self.dataArr[indexPath.row]);
//iOS11后打开UIImagePickerController不需要权限
                    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                    imagePickerController.view.tag = 55;
                    imagePickerController.allowsEditing = NO;
                    imagePickerController.delegate = self;
                    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    [self presentViewController:imagePickerController animated:YES completion:^{
                        
                    }];
                } else {
                    NSLog(@"未获得%@权限",self.dataArr[indexPath.row]);
                }
            }];
            break;
        }
        case 1: {
            [[CJXPermissionsManage sharedInstance] getNetworkPermissions:^(BOOL authorized) {
                if (authorized) {
                    WKWebView *wkweb = [[WKWebView alloc] initWithFrame:CGRectMake(0, UIScreenHeight - 150, UIScreenWidth, 150)];
                    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
                    NSURLRequest *request = [NSURLRequest requestWithURL:url];
                    [wkweb loadRequest:request];
                    [self.view addSubview:wkweb];
                    NSLog(@"获得%@权限",self.dataArr[indexPath.row]);
                } else {
                    NSLog(@"未获得%@权限",self.dataArr[indexPath.row]);
                }
            }];
            break;
        }
        case 2: {
            [[CJXPermissionsManage sharedInstance] getCameraPermissions:^(BOOL authorized) {
                if (authorized) {
                    NSLog(@"获得%@权限",self.dataArr[indexPath.row]);
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"本地相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        _imagePickerController = [[UIImagePickerController alloc] init];
                        _imagePickerController.allowsEditing = YES;
                        _imagePickerController.delegate = self;
                        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                        //闪光灯设置
                        //_imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                        [self presentViewController:_imagePickerController animated:YES completion:^{
                            
                        }];
                    }];
                    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"自定义相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        CJXCamera *camera = [[CJXCamera alloc] initWithFrame:self.view.bounds block:^(UIImage *image) {
                            if (image) {
                                if (self.cameraArr.count > 0) {
                                    [self.cameraArr removeAllObjects];
                                }
                                [self.cameraArr addObject:image];
                                [self.tableView reloadData];
                            }
                        }];
                    }];
                    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"扫描二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        JXQRController *qr = [[JXQRController alloc]init];
                        [self.navigationController pushViewController:qr animated:YES];
                    }];
                    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    [alert addAction:action1];
                    [alert addAction:action2];
                    [alert addAction:action3];
                    [alert addAction:action4];
                    [self presentViewController:alert animated:YES completion:nil];
                } else {
                    NSLog(@"未获得%@权限",self.dataArr[indexPath.row]);
                }
            }];
            break;
        }
        case 3: {
            [[CJXPermissionsManage sharedInstance] getAddressBookPermissions:^(BOOL authorized) {
                if (authorized) {
                    CNContactPickerViewController *contact = [[CNContactPickerViewController alloc] init];
                    contact.delegate = self;
                    [self presentViewController:contact animated:YES completion:nil];
                    NSLog(@"获得%@权限",self.dataArr[indexPath.row]);
                } else {
                    NSLog(@"未获得%@权限",self.dataArr[indexPath.row]);
                }
            }];
            break;
        }
        case 4: {
            [[CJXPermissionsManage sharedInstance] getAlwaysLocationPermissions:YES completion:^(BOOL authorized) {
                if (authorized) {
                    NSLog(@"获得%@权限",self.dataArr[indexPath.row]);
                    self.locationManager = [[CLLocationManager alloc] init];
                    self.locationManager.delegate = self;
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                    self.locationManager.distanceFilter = 5.0;
                    [self.locationManager startUpdatingLocation];
                } else {
                    NSLog(@"未获得%@权限",self.dataArr[indexPath.row]);
                }
            }];
            break;
        }
        case 5: {
            [[CJXPermissionsManage sharedInstance] getAlwaysLocationPermissions:NO completion:^(BOOL authorized) {
                if (authorized) {
                    NSLog(@"获得%@权限",self.dataArr[indexPath.row]);
                    self.locationManager = [[CLLocationManager alloc] init];
                    self.locationManager.delegate = self;
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                    self.locationManager.distanceFilter = 5.0;
                    [self.locationManager startUpdatingLocation];
                } else {
                    NSLog(@"未获得%@权限",self.dataArr[indexPath.row]);
                }
            }];
            break;
        }
        case 6: {
            [[CJXPermissionsManage sharedInstance] getMicrophonePermissions:^(BOOL authorized) {
                if (authorized) {
                    AudioRecorderViewController *ar = [AudioRecorderViewController new];
                    [self presentViewController:ar animated:YES completion:nil];
                    NSLog(@"获得%@权限",self.dataArr[indexPath.row]);
                } else {
                    NSLog(@"未获得%@权限",self.dataArr[indexPath.row]);
                }
            }];
            break;
        }
        case 7: {
            [[CJXPermissionsManage sharedInstance] getSpeechRecognitionPermissions:^(BOOL authorized) {
                if (authorized) {
                    NSLog(@"获得%@权限",self.dataArr[indexPath.row]);
                    PhoneticRecognitionVC *pn = [PhoneticRecognitionVC new];
                    [self presentViewController:pn animated:YES completion:nil];
                } else {
                    NSLog(@"未获得%@权限",self.dataArr[indexPath.row]);
                }
            }];
            break;
        }
        case 8: {
            [[CJXPermissionsManage sharedInstance] getPushPermissions:^(BOOL authorized) {
                if (authorized) {
                    [self creatMsg];
                } else {
                    
                }
            }];
            
            break;
        }
        default:
            break;
    }
}
//最好放在appdelegate里面
- (void)registerNotifications {
    //iOS10特有
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    // 必须写代理，不然无法监听通知的接收与点击
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            // 点击允许
            NSLog(@"注册成功");
            [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                NSLog(@"%@", settings);
            }];
        } else {
            // 点击不允许
            NSLog(@"注册失败");
        }
    }];
    //远程推送获取
    // 注册获得device Token
    //    [[UIApplication sharedApplication] registerForRemoteNotifications];
    //获取未触发的通知
    [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        NSLog(@"pending: %@", requests);
    }];
    //获取通知中心列表的通知
    [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
        NSLog(@"Delivered: %@", notifications);
    }];
    //清除某一个未触发的通知
    [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[@"TestRequest1"]];
    //清除某一个通知中心的通知
    [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[@"TestRequest2"]];
    //对应的删除所有通知
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
}
- (void)creatMsg {
    
//    // 1.创建一个UNNotificationRequest
//    NSString *requestIdentifer = @"TestRequest";
//    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifer content:content trigger:trigger];
//    
//    // 2.将UNNotificationRequest类，添加进当前通知中心中
//    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//        
//    }];
    // 1.创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"测试通知";
    content.body = @"通知内容";
    content.badge = @1;
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"uget" ofType:@"png"];
    UNNotificationAttachment *att = [UNNotificationAttachment attachmentWithIdentifier:@"att1" URL:[NSURL fileURLWithPath:path] options:nil error:&error];
    if (error) {
        NSLog(@"attachment error %@", error);
    }
    content.attachments = @[att];
    content.launchImageName = @"tupian";
    // 2.设置声音
    UNNotificationSound *sound = [UNNotificationSound defaultSound];
    content.sound = sound;
    // 3.触发模式
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:2 repeats:NO];
    
    // 4.设置UNNotificationRequest
    NSString *requestIdentifer = @"TestRequest";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifer content:content trigger:trigger];
    
    //5.把通知加到UNUserNotificationCenter, 到指定触发点会被触发
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}
// 获得Device Token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
}
// 获得Device Token失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
// iOS 10收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 前台收到远程通知");
        
    } else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}
// 通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知");
        
    } else {
        // 判断为本地通知
        
        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
    completionHandler();  // 系统要求执行这个方法
    
}
#pragma mark - 定位代理
//定位代理经纬度回调
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
    CLLocation *location = locations.lastObject;
    NSTimeInterval locationAge = [[(CLLocation *)[locations lastObject] timestamp] timeIntervalSinceNow];
    NSLog(@"how old the location is: %.5f", locationAge);

    location = [location locationMarsFromEarth];
    NSLog(@"纬度是:%f,经度是:%f",location.coordinate.latitude,location.coordinate.longitude);
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            CLPlacemark *placemark = placemarks.firstObject;
            //获取城市
            NSString *city = placemark.locality;
            if (!city) {
                city = placemark.administrativeArea;
            }
            NSLog(@"city:%@", city);
            self.city = placemark.name;
            [self.tableView reloadData];
            MapViewController *map = [[MapViewController alloc] init];
            map.latitude = location.coordinate.latitude;
            map.longitude = location.coordinate.longitude;
            map.city = city;
            [self presentViewController:map animated:YES completion:nil];
        } else if (error == nil && [placemarks count] == 0) {
            NSLog(@"No results were returned.");
        } else if (error != nil) {
            NSLog(@"An error occurred = %@", error);
        }
    }];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
}
#pragma mark - 通讯录代理
//选中一个人
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    NSLog(@"%@",contact);
    for (CNLabeledValue *value in contact.phoneNumbers) {
        CNPhoneNumber *phone = value.value;
        self.address = phone.stringValue;
        [self.tableView reloadData];
        NSLog(@"%@",phone.stringValue);
    }
}
//选中一个人属性
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    NSLog(@"%@",contactProperty);
}
//选中多个联系人
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts {
    NSLog(@"%@",contacts);
    for (CNLabeledValue *value in contacts.firstObject.phoneNumbers) {
        CNPhoneNumber *phone = value.value;
        self.address = phone.stringValue;
        [self.tableView reloadData];
        NSLog(@"%@",phone.stringValue);
    }
}
//选中多个联系人属性
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperties:(NSArray<CNContactProperty *> *)contactProperties {
    NSLog(@"%@",contactProperties);

}
#pragma mark - 相册代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (!image) {
        return;
    }
    if (picker.view.tag == 55) {
        if (self.photoArr.count > 0) {
            [self.photoArr removeAllObjects];
        }
        [self.photoArr addObject:image];
    } else {
        if (self.cameraArr.count > 0) {
            [self.cameraArr removeAllObjects];
        }
        [self.cameraArr addObject:image];
    }
    [self.tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = 40;
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, headerHeight)];
    return headerView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
