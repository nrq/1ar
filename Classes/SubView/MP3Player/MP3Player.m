//
//  MP3Player.m
//  PTMusicApp
//
//  Created by hieu nguyen on 1/24/15.
//  Copyright (c) 2015 Fruity Solution. All rights reserved.
//

#import "MP3Player.h"
#import "DatabaseManager.h"
#import "ModelManager.h"
#import "Validator.h"
#import "PlaySongViewController.h"

@interface MP3Player ()

@end

@implementation MP3Player

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLbl.textColor = [UIColor whiteColor];
    self.nameLbl.font = [UIFont systemFontOfSize:14];
    self.artistLbl.textColor = [UIColor whiteColor];
    self.artistLbl.font = [UIFont systemFontOfSize:10];
    self.artistLbl.scrollDuration = self.song.desc.length;

    self.songArr = [[DatabaseManager defaultDatabaseManager]getAllSongwithPlaylist:CURRENT_PLAYLIST];
    NSString *current = [Util objectForKey:CURRENT_SONG_ID_KEY];
    if (self.songArr.count == 0 && current.length == 0) {
        self.view.hidden = YES;
    }
    
    for (Song *s in gMP3Player.songArr) {
        NSLog(@"song: %@ save: %@",s.songId,current);
        if ([s.songId isEqualToString:current]) {
            self.song = s;
            break;
        }
    }
    NSURL *urlAudio = [Util getAudioURLForLink:self.song.link];
    
    currentAudio = self.song.songId;
    _audioPlayer = [AVPlayer playerWithURL:urlAudio];
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:self.song.link] options:nil];
    
    CMTime audioDuration = audioAsset.duration;
    
    audioDurationInSecond = CMTimeGetSeconds(audioDuration);
    
    self.nameLbl.text = self.song.name;
    self.artistLbl.text = self.song.desc;
    // Do any additional setup after loading the view from its nib.
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!success) { /* handle the error condition */ }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) {}
    
    [self showOrHide];
}

-(void) showOrHide{
    if (self.song.songId.length == 0)
        self.view.hidden = YES;
    else
        self.view.hidden = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)play{
    NSLog(@"play from MP3Player");
    
    NSURL *urlAudio = [Util getAudioURLForLink:self.song.link];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:urlAudio];
    NSArray *tracks = [playerItem tracks];
    for (AVPlayerItemTrack *playerItemTrack in tracks)
    {
        // find video tracks
        if ([playerItemTrack.assetTrack hasMediaCharacteristic:AVMediaCharacteristicVisual])
        {
            playerItemTrack.enabled = NO; // disable the track
        }
    }
    
    _audioPlayer = [AVPlayer playerWithURL:urlAudio];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    
    // checking if there's a forward
    CMTime toAdvance = [self loadCurrentTimeWithKey:currentAudio];
    

    [_audioPlayer play];
    [_audioPlayer seekToTime:toAdvance];

}

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    float currentTimeInSecond = CMTimeGetSeconds([_audioPlayer currentTime]);
    // deleting record
    [self deleteRecord:currentAudio];
    
    if (currentTimeInSecond > audioDurationInSecond-1) {
        [ModelManager updateSong:self.song.songId path:LISTEN_SONG WithSuccess:^(NSDictionary *dic) {
            NSDictionary *songDic = dic[@"data"];
            self.song.viewNum = [Validator getSafeString:songDic[@"view"]];
        } failure:^(NSString *err) {
            
        }];
    }
}

#pragma mark - Time presistance layer


-(void)deleteRecord:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
}

- (void)saveCurrenttTime:(NSString *)key {
    NSLog(@"Saving time");
    CMTime cmTime = _audioPlayer.currentTime;
    NSLog(@"%lld",cmTime.value);

    CFDictionaryRef timeAsDictionary = CMTimeCopyAsDictionary(cmTime, kCFAllocatorDefault);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:(__bridge id _Nullable)(timeAsDictionary) forKey:key];
    [defaults synchronize];
    
}

- (CMTime)loadCurrentTimeWithKey:(NSString *)key {
    NSLog(@"loading saved time");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CFDictionaryRef encodedObject = (__bridge CFDictionaryRef)([defaults objectForKey:key]);
    CMTime object = CMTimeMakeFromDictionary(encodedObject);
    return object;
}

#pragma mark - Outlets



- (IBAction)onPrevious:(id)sender {
    [self saveCurrenttTime:currentAudio];
    if (_isShuffer) {
        self.index =arc4random_uniform((int)self.songArr.count);
    }
    else{
        self.index --;
    }
    if (self.index<0) {
        self.index = (int)self.songArr.count -1;
    }
    self.song = [self.songArr objectAtIndex:self.index];
    self.nameLbl.text = self.song.name;
    self.artistLbl.text = self.song.desc;
    currentAudio = self.song.songId;
    [Util setObject:self.song.songId forKey:CURRENT_SONG_ID_KEY];
    [self play];
}

- (IBAction)onNext:(id)sender {
    [self saveCurrenttTime:currentAudio];

    if (_isShuffer) {
        self.index =arc4random_uniform((int)self.songArr.count);
    }
    else{
        self.index ++;
    }
    if (self.index>=self.songArr.count) {
        self.index = 0;
    }
    
    NSLog(@"songs %lu index %d", self.songArr.count, self.index);
    self.song = [self.songArr objectAtIndex:self.index];
    self.nameLbl.text = self.song.name;
    self.artistLbl.text = self.song.desc;
    [self play];
    currentAudio = self.song.songId;
    [Util setObject:self.song.songId forKey:CURRENT_SONG_ID_KEY];
}

- (IBAction)onPlayPause:(id)sender {
    [self saveCurrenttTime:currentAudio];

    _isPlaying = !_isPlaying;
    if(_isPlaying)
    {
        [_audioPlayer play];
        [self.pauseBtn setBackgroundImage:[UIImage imageNamed:@"btn_pause.png"] forState:UIControlStateNormal];
        
    }else
    {
        [self.pauseBtn setBackgroundImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
        NSLog(@"onPlayPause.pause");
        [_audioPlayer pause];
        
    }
}

- (IBAction)OnNextDetail:(id)sender {
    if (self.songArr.count>0) {
        [self.delegate NextDetailWithSongArr:self.songArr andInde:self.index];
    }
}
-(int) getHeight
{
    if (self.view.frame.size.height == 0)
        return 50;
    else
        return self.view.frame.size.height;
}
@end
