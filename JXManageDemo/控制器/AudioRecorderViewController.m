//
//  AudioRecorderViewController.m
//  CJXDemo
//
//  Created by tet-cjx on 2017/7/4.
//  Copyright © 2017年 hyd-cjx. All rights reserved.
//

#import "AudioRecorderViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioRecorderViewController ()<AVAudioRecorderDelegate>
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (nonatomic, strong) AVCaptureSession *captureSession;//数据传递
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSURL *recordFileUrl; //文件地址
@property (nonatomic, strong) AVAudioSession *session;

@end

@implementation AudioRecorderViewController {
    NSString *filePath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)start:(id)sender {
    [self startAudioRecorder];
}
- (IBAction)stop:(id)sender {
    if ([self.recorder isRecording]) {
        [self.recorder stop];
        NSLog(@"停止录音");
    }
    
}
- (IBAction)play:(id)sender {
    NSLog(@"播放录音");
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
    if ([self.player isPlaying])return;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileUrl error:nil];
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.player play];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        _duration.text = [NSString stringWithFormat:@"录了%0.f秒,文件大小为%.2fKb",self.player.duration,[[manager attributesOfItemAtPath:filePath error:nil] fileSize]/1024.0];
    }
}
//简单录音
- (void)startAudioRecorder {
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if (session == nil) {
        NSLog(@"Error creating session: %@",[sessionError description]);
    } else {
        [session setActive:YES error:nil];
    }
    self.session = session;
    //1.获取沙盒地址
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [path stringByAppendingString:@"/RRecord.wav"];
    //2.获取文件路径
    self.recordFileUrl = [NSURL fileURLWithPath:filePath];
    //设置参数
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                                   // 音频格式
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   //采样位数  8、16、24、32 默认为16
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   // 音频通道数 1 或 2
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   //录音质量
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];
    NSError *error = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:_recordFileUrl settings:recordSetting error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    if (_recorder) {
        //准备录音
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        [_recorder record];
    } else {
        NSLog(@"音频格式和文件存储格式不匹配,无法初始化Recorder");
    }
    _recorder.delegate = self;
    
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        // 录音正常结束
        NSData *data = [NSData dataWithContentsOfURL:_recordFileUrl];
        NSLog(@"%u",data.length/1024);
    } else {
        // 未正常结束
        if ([_recorder deleteRecording]) {
            // 录音文件删除成功
            NSLog(@"录音文件删除成功");
        } else {
            // 录音文件删除失败
        }
    }
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
