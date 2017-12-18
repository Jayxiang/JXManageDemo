//
//  CuijxQRController.m
//  CJXQRscan
//
//  Created by Lever丶 on 2016/12/22.
//  Copyright © 2016年 Messageinfo. All rights reserved.
//

#import "JXQRController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHPhotoLibrary.h>

#define kScreenSize [UIScreen mainScreen].bounds.size

@interface JXQRController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIImageView *_line;
    NSInteger num;
    BOOL upOrdown;
    NSTimer *timer;
}
@property (weak, nonatomic) IBOutlet UIImageView *bocImage;
@property (weak, nonatomic) IBOutlet UILabel *remindLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *preView;

@property (nonatomic)AVCaptureDevice *device;
@property(nonatomic)AVCaptureDeviceInput *input;
@property(nonatomic)AVCaptureMetadataOutput *output;
@property(nonatomic)AVCaptureSession *session;
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation JXQRController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.delegate = self;
    
    [self initLine];
    [self openCamera];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = self.bocImage.frame;
}

- (void)openCamera {
    //AVMediaTypeVideo 指定视频输入，defaultDevice 默认使用后置摄像头
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //使用device产生输入
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    //生成Metadata 类型的输出，这样就可以产生某种类型的输出譬如二维码
    self.output = [[AVCaptureMetadataOutput alloc]init];
    //一旦捕获到指定类型的视频帧，就调用在指定的队列上调用代理方法
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //生成session,把输入输出粘合在一起
    self.session = [[AVCaptureSession alloc]init];
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    //设置类型要写到添加到session后
    //AVMetadataObjectTypeQRCode 值定metaData为二维码的编码
    [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    //生成预览层，把捕获的视频展示到手机上
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    
    //指定图片填充模式，保持宽高比不变对bounds进行填充
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.backView.layer insertSublayer:self.previewLayer below:self.bocImage.layer];
    
    //就开始启动，这就开始启动摄像头的捕获功能
    [self.session startRunning];
}

- (void)initLine{
    
    upOrdown = NO;
    num = 0;
    _line = [[UIImageView alloc]init];
    //_line.frame = CGRectMake(0, 0, self.bocImage.frame.size.height, 8);
    _line.image = [UIImage imageNamed:@"scaningline"];
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
    [self.view addSubview:_line];
    
}
//扫描结果
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    [self.session stopRunning];
    if ([metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *object = [metadataObjects firstObject];
        self.remindLabel.text = object.stringValue;
    }
}

//在这才能获取到正在frame
- (void)viewDidAppear:(BOOL)animated {
    
}

//页面将要进入前台，开启定时器
-(void)viewWillAppear:(BOOL)animated {
    //开启定时器
    [timer setFireDate:[NSDate distantPast]];
}

//页面消失，进入后台不显示该页面，关闭定时器
-(void)viewDidDisappear:(BOOL)animated {
    //关闭定时器
    [timer setFireDate:[NSDate distantFuture]];
    
}

-(void)animation1 {
    
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(self.bocImage.frame.origin.x, self.bocImage.frame.origin.y+2*num, self.bocImage.frame.size.height, 8);
        if (2*num >= self.bocImage.frame.size.height-10) {
            upOrdown = YES;
        }
    } else {
        num --;
        _line.frame = CGRectMake(self.bocImage.frame.origin.x, self.bocImage.frame.origin.y+2*num, self.bocImage.frame.size.height, 8);
        if (num <= 0) {
            upOrdown = NO;
        }
    }
    
}

- (IBAction)popClick:(id)sender {
    [timer invalidate];
    timer = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goPhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    
    //ios8后
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        //无权限
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:@"您的手机没有打开访问权限" preferredStyle:UIAlertControllerStyleAlert];
        [alertView addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertView animated:YES completion:nil];
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:^{}];
        [self.session stopRunning];
    }
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            NSLog(@"获得权限");
        } else {
            NSLog(@"未获得权限");
        }
    }];
    
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIImage *qrImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!qrImage) {
        qrImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode  context:nil options:@{ CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *image = [CIImage imageWithCGImage:qrImage.CGImage];
    NSArray *features = [detector featuresInImage:image];
    if (features.count >=1) {
        for (CIQRCodeFeature *feature in features) {
            self.remindLabel.text = feature.messageString;
            NSLog(@"--%@", feature.messageString);
        };
    } else {
        NSLog(@"这不是二维码");
    }
    
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //NSLog(@"123");
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.session startRunning];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL isShow = [viewController isKindOfClass:[UIImagePickerController class]];
    BOOL isShowHome = [viewController isKindOfClass:[self class]];
    if (isShowHome || isShow) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
