//
//  PhoneticRecognitionVC.m
//  CJXDemo
//
//  Created by tet-cjx on 2017/7/4.
//  Copyright © 2017年 hyd-cjx. All rights reserved.
//

#import "PhoneticRecognitionVC.h"
#import <Speech/Speech.h>
#import <AVFoundation/AVFoundation.h>

API_AVAILABLE(ios(10.0))
@interface PhoneticRecognitionVC ()<SFSpeechRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *result;
@property (weak, nonatomic) IBOutlet UIButton *localBtn;
@property (weak, nonatomic) IBOutlet UIButton *nowBtn;
@property (nonatomic,strong) AVAudioEngine *audioEngine;
@property (nonatomic,strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic,strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic,strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;

@end

@implementation PhoneticRecognitionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)localClick:(id)sender {
    NSLocale *local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    if (@available(iOS 10.0, *)) {
        SFSpeechRecognizer *localRecognizer =[[SFSpeechRecognizer alloc] initWithLocale:local];
        NSURL *url =[[NSBundle mainBundle] URLForResource:@"录音.m4a" withExtension:nil];
        if (!url) return;
        SFSpeechURLRecognitionRequest *res =[[SFSpeechURLRecognitionRequest alloc] initWithURL:url];
        [localRecognizer recognitionTaskWithRequest:res resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            if (error) {
                NSLog(@"语音识别解析失败,%@",error);
            } else {
                self.result.text = result.bestTranscription.formattedString;
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}
- (IBAction)nowClick:(id)sender {
    if (self.audioEngine.isRunning) {
        [self.audioEngine stop];
        if (_recognitionRequest) {
            [_recognitionRequest endAudio];
        }
        self.nowBtn.enabled = NO;
        [self.nowBtn setTitle:@"正在停止" forState:UIControlStateDisabled];
        
    } else {
        [self startRecording];
        [self.nowBtn setTitle:@"停止录音" forState:UIControlStateNormal];
        
    }
}
- (void)startRecording{
    if (_recognitionTask) {
        [_recognitionTask cancel];
        _recognitionTask = nil;
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    NSParameterAssert(!error);
    [audioSession setMode:AVAudioSessionModeMeasurement error:&error];
    NSParameterAssert(!error);
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    NSParameterAssert(!error);

    if (@available(iOS 10.0, *)) {
        _recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
        AVAudioInputNode *inputNode = self.audioEngine.inputNode;
        NSAssert(inputNode, @"录入设备没有准备好");
        NSAssert(_recognitionRequest, @"请求初始化失败");
        _recognitionRequest.shouldReportPartialResults = YES;
        __weak typeof(self) weakSelf = self;
        _recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:_recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            BOOL isFinal = NO;
            if (result) {
                strongSelf.result.text = result.bestTranscription.formattedString;
                isFinal = result.isFinal;
            }
            if (error || isFinal) {
                [self.audioEngine stop];
                [inputNode removeTapOnBus:0];
                strongSelf.recognitionTask = nil;
                strongSelf.recognitionRequest = nil;
                strongSelf.nowBtn.enabled = YES;
                strongSelf.result.text = [NSString stringWithFormat:@"%@",error.localizedDescription];
                [strongSelf.nowBtn setTitle:@"开始录音" forState:UIControlStateNormal];
            }
            
        }];
        
        AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
        [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.recognitionRequest) {
                [strongSelf.recognitionRequest appendAudioPCMBuffer:buffer];
            }
        }];
        
        [self.audioEngine prepare];
        [self.audioEngine startAndReturnError:&error];
        NSParameterAssert(!error);
        self.result.text = @"正在录音...";
    } else {
        // Fallback on earlier versions
    }
    
}
#pragma mark - lazyload
- (AVAudioEngine *)audioEngine{
    if (!_audioEngine) {
        _audioEngine = [[AVAudioEngine alloc] init];
    }
    return _audioEngine;
}
- (SFSpeechRecognizer *)speechRecognizer API_AVAILABLE(ios(10.0)){
    if (!_speechRecognizer) {
        //语音识别对象设置语言，这里设置的是中文
        NSLocale *local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        
        _speechRecognizer =[[SFSpeechRecognizer alloc] initWithLocale:local];
        _speechRecognizer.delegate = self;
    }
    return _speechRecognizer;
}
#pragma mark - SFSpeechRecognizerDelegate
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available API_AVAILABLE(ios(10.0)){
    if (available) {
        self.nowBtn.enabled = YES;
        [self.nowBtn setTitle:@"开始录音" forState:UIControlStateNormal];
    } else {
        self.nowBtn.enabled = NO;
        [self.nowBtn setTitle:@"语音识别不可用" forState:UIControlStateDisabled];
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
