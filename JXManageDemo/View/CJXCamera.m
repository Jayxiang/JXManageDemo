//
//  CJXCamera.m
//  CJXDemo
//
//  Created by tet-cjx on 2017/7/10.
//  Copyright © 2017年 hyd-cjx. All rights reserved.
//

#import "CJXCamera.h"
#import <AVFoundation/AVFoundation.h>

#define UIScreenWidth [[UIScreen mainScreen] bounds].size.width
#define UIScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface CJXCamera ()

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic)AVCaptureDevice *device;
//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;
//当启动摄像头开始捕获输入
@property(nonatomic)AVCaptureMetadataOutput *output;
@property (nonatomic)AVCaptureStillImageOutput *ImageOutPut;
//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;
//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *chooseBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *focusView;
@property (nonatomic, assign) BOOL isflashOn;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) void (^getImage)(UIImage *image);

@end

@implementation CJXCamera

- (instancetype)initWithFrame:(CGRect)frame block:(void(^)(UIImage *image))block {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self creatCamera];
        [self creatUI];
        self.getImage = block;
        self.frame = CGRectMake(0, UIScreenHeight, UIScreenWidth, UIScreenHeight);
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight);
        }];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self];
    }
    return self;
}

- (void)creatCamera {
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //使用设备初始化输入
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    
    //生成输出对象
    self.output = [[AVCaptureMetadataOutput alloc]init];
    self.ImageOutPut = [[AVCaptureStillImageOutput alloc] init];
//    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
//    [self.ImageOutPut setOutputSettings:outputSettings];
    //生成会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc]init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.ImageOutPut]) {
        [self.session addOutput:self.ImageOutPut];
    }
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:self.previewLayer];
    //开始启动
    [self.session startRunning];
    
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    if ([_device lockForConfiguration:nil]) {
        //自动闪光灯
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
            
        }
        //自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
//        //需要的时候自动白平衡
//        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
//            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
//        }
//        //自动对焦
//        if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
//            [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
//        }
//        //自动曝光
//        if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
//            [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
//        }
        [_device unlockForConfiguration];
    }
}
- (void)creatUI{
    _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _photoButton.frame = CGRectMake(UIScreenWidth/3, UIScreenHeight - 100, UIScreenWidth/3, 60);
    [_photoButton setImage:[UIImage imageNamed:@"photograph"] forState: UIControlStateNormal];
    [_photoButton setImage:[UIImage imageNamed:@"photograph_Select"] forState:UIControlStateNormal];
    [_photoButton addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_photoButton];
    
    _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _focusView.layer.borderWidth = 1.0;
    _focusView.layer.borderColor =[UIColor greenColor].CGColor;
    _focusView.backgroundColor = [UIColor clearColor];
    [self addSubview:_focusView];
    _focusView.hidden = YES;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, UIScreenHeight - 100, UIScreenWidth/3, 60);
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [leftButton addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(UIScreenWidth/3*2, UIScreenHeight - 100, UIScreenWidth/3, 60);
    [rightButton setTitle:@"切换" forState:UIControlStateNormal];
    rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [rightButton addTarget:self action:@selector(changeCamera) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightButton];
    
    _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _flashButton.frame = CGRectMake(UIScreenWidth - 60, 10, 48, 48);
    [_flashButton setImage:[UIImage imageNamed:@"闪光灯-关闭"] forState: UIControlStateNormal];
    [_flashButton setImage:[UIImage imageNamed:@"闪光灯"] forState: UIControlStateSelected];
    [_flashButton addTarget:self action:@selector(flashOn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_flashButton];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self addGestureRecognizer:tapGesture];
}
#pragma mark - 截取照片
- (void)shutterCamera {
    AVCaptureConnection *videoConnection = [self.ImageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    //设置前置摄像头镜像翻转
    AVCaptureDevicePosition currentPosition=[[self.input device] position];
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        videoConnection.videoMirrored = YES;
    } else {
        videoConnection.videoMirrored = NO;
    }
    [self.ImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        self.image = [UIImage imageWithData:imageData];
        
        [self.session stopRunning];
        self.imageView = [[UIImageView alloc]initWithFrame:self.previewLayer.frame];
        [self addSubview:self.imageView];
        self.imageView.layer.masksToBounds = YES;
        self.imageView.image = _image;
        self.focusView.hidden = YES;
        _chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _chooseBtn.frame = CGRectMake(UIScreenWidth - 74, UIScreenHeight - 100, 60, 60);
        [_chooseBtn setTitle:@"选择" forState:UIControlStateNormal];
        [_chooseBtn addTarget:self action:@selector(chooseClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_chooseBtn];
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(20, UIScreenHeight - 100, 60, 60);
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancleClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelBtn];
        NSLog(@"image size = %@",NSStringFromCGSize(self.image.size));
    }];
}

- (void)changeCamera{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        
        CATransition *animation = [CATransition animation];
        
        animation.duration = .5f;
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        } else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:_input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
                
            } else {
                [self.session addInput:self.input];
            }
            
            [self.session commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}
- (void)flashOn{
    if (![self.device hasFlash]) {
        return;
    }
    if ([_device lockForConfiguration:nil]) {
        if (_isflashOn) {
            if ([_device isFlashModeSupported:AVCaptureFlashModeOff]) {
                [_device setFlashMode:AVCaptureFlashModeOff];
                _isflashOn = NO;
                _flashButton.selected = NO;
            }
        } else {
            if ([_device isFlashModeSupported:AVCaptureFlashModeOn]) {
                [_device setFlashMode:AVCaptureFlashModeOn];
                _isflashOn = YES;
                _flashButton.selected = YES;
            }
        }
        [_device unlockForConfiguration];
    }
}
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}
- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                _focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _focusView.hidden = YES;
            }];
        }];
    }
}
- (void)chooseClick:(UIButton *)sender {
    self.getImage(self.image);
    [self cancle];
}
- (void)cancleClick:(UIButton *)sender {
    sender.hidden = YES;
    _chooseBtn.hidden = YES;
    [self.imageView removeFromSuperview];
    [self.session startRunning];
}
-(void)cancle{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, UIScreenHeight, UIScreenWidth, UIScreenHeight);;
    }completion:^(BOOL finished) {
        [self.session stopRunning];
        [self removeFromSuperview];
    }];
    
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
