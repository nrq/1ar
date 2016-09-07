//
//  PlaySongViewController.m
//  PTMusicApp
//
//  Created by hieu nguyen on 12/20/14.
//  Copyright (c) 2014 Fruity Solution. All rights reserved.
//

#import "PlaySongViewController.h"
#import "MBProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "MP3Player.h"
#import "DatabaseManager.h"
#import "TopSongCell.h"
#import "REPagedScrollView.h"
#import "UIImageView+WebCache.h"
#import "ModelManager.h"
#import "Validator.h"
#import "ShowPlayListViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "AsyncImageView.h"
#import "WebViewController.h"
#import "CustomButton.h"
#import "BannerItem.h"
#import "AppDelegate.h"

@interface PlaySongViewController ()<ShowPlayListViewControllerDelegate>
@end

@implementation PlaySongViewController{
    NSArray *arrayBanner;
    UIImageView *imgVBanner;
    UIView *viewBanner ;
    CustomButton *btnBanner;
    NSTimer *bannerTimer;
}

-(void)closeMenu{
    backgroundLabel.hidden = YES;
    UIButton *button1=[UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setFrame:CGRectMake(SCREEN_WIDTH_PORTRAIT-130, 35, 120.0, 30.0)];
    if(dropDown == nil) {}
    else {
        [dropDown hideDropDown:button1];
        [self rel];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fixMultiScreenSize];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)];
    tapGesture.cancelsTouchesInView = NO;
    
    backgroundLabel = [[UILabel alloc]initWithFrame:self.view.frame];
    backgroundLabel.userInteractionEnabled = YES;
    [backgroundLabel addGestureRecognizer:tapGesture];
    
    [self.view addSubview: backgroundLabel];
    backgroundLabel.hidden = YES;
    
    
    CGRect rect = self.pageView.frame;
    
    rect.size.width = SCREEN_WIDTH_PORTRAIT;
    REPagedScrollView *scrollView = [[REPagedScrollView alloc] initWithFrame:rect];
    
    scrollView.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:169/255.0 green:169/255.0 blue:169/255.0 alpha:1.0];
    scrollView.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:77/255.0 green:56/255.0 blue:65/255.0 alpha:1.0];
    [self.view addSubview:scrollView];
    
    [self.tblView setBackgroundColor:[UIColor clearColor]];
    self.tblView.separatorColor = [UIColor clearColor];
    //[self.view2 setBackgroundColor:[UIColor redColor]];
    [scrollView addPage:self.view2];
    
    [scrollView addPage:self.view1];
    [scrollView scrollToPageWithIndex:1 animated:NO];
    //[scrollView setBackgroundColor:[UIColor redColor]];
    //[self.pageView setBackgroundColor:[UIColor greenColor]];
    
    Song *s = [self.songArr objectAtIndex:self.index];
    if (![currentAudio isEqualToString:s.songId]){
        gMP3Player.song = [self.songArr objectAtIndex:self.index];
 
    }
    
    self.downloadLbl.text = gMP3Player.song.downloadNum;
    self.viewLbl.text = gMP3Player.song.viewNum;
    [self setRepeatBtn];
    [self setShuffleBtn];
    if (!self.pauseOnLoad){
        [self play];
    }
    else
    {
        [self fillSongInfo];// re-fill info when on pause
    }
    self.songNameLbl.textAlignment = NSTextAlignmentCenter;
    self.songNameLbl.font =[UIFont boldSystemFontOfSize:16];
    self.songNameLbl.textColor = [UIColor colorWithRed:77/255.0 green:56/255.0 blue:65/255.0 alpha:1.0];
    self.artistNameLbl.textAlignment = NSTextAlignmentCenter;
    self.artistNameLbl.font = [UIFont systemFontOfSize:12];
    self.artistNameLbl.textColor = [UIColor colorWithRed:77/255.0 green:56/255.0 blue:65/255.0 alpha:1.0];
    [self.view bringSubviewToFront:self.footerView];
    [self.footerView bringSubviewToFront:_slider];
    // Do any additional setup after loading the view from its nib.
    
    [self createBanner];
    [self.view bringSubviewToFront:backgroundLabel];


   
}

-(void)createBanner{
    
    viewBanner = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                          SCREEN_HEIGHT_PORTRAIT - 50,
                                                          SCREEN_WIDTH_PORTRAIT,
                                                          50)];
    viewBanner.backgroundColor = [UIColor clearColor];
    [self.view addSubview:viewBanner];
    [self.view bringSubviewToFront:viewBanner];
    
    imgVBanner = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewBanner.frame.size.width, viewBanner.frame.size.height)];
    [viewBanner addSubview:imgVBanner];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ModelManager getBannerWithType:@"0" WithSuccess:^(NSArray *arr) {
            arrayBanner = arr;
            
            BannerItem *b = arr[0];
            imgVBanner.imageURL = [NSURL URLWithString:b.bannerImage];
            
            btnBanner = [CustomButton buttonWithType:UIButtonTypeCustom];
            btnBanner.frame = imgVBanner.frame;
            [btnBanner addTarget:self action:@selector(touchBanner:) forControlEvents:UIControlEventTouchUpInside];
            btnBanner.userData = b;
            [viewBanner addSubview:btnBanner];
            
            bannerTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(changeBanner) userInfo:nil repeats:YES];
            
        } failure:^(NSString *err) {
            
        }];
    });
}


-(void)viewWillAppear:(BOOL)animated{
//    [self.view addSubview:adBanner.view];
//    [self.view bringSubviewToFront:adBanner.view];
    //[self.footerView setHidden:TRUE];
    
   
}

-(int)randomFromZeroTo:(int)number{
    return arc4random_uniform(number);
}

-(void)changeBanner{
    NSLog(@"change Banner");
    if (arrayBanner.count > 0) {
        int index = [self randomFromZeroTo:(int)arrayBanner.count];
        BannerItem *b = arrayBanner[index];
        btnBanner.userData = b;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                imgVBanner.imageURL = [NSURL URLWithString:b.bannerImage];
        });

        
    }
    
}

-(void)touchBanner:(CustomButton*)btn{
    WebViewController *controller = [[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil];
    controller.item = btn.userData;
    [self presentViewController:controller animated:YES completion:nil];
}

-(void) fixMultiScreenSize{
    int footerHeightView = 125;
    int heightOfPagingCircle = 36;
    
    
    self.pageView.frame=CGRectMake(self.pageView.frame.origin.x, self.pageView.frame.origin.y, SCREEN_WIDTH_PORTRAIT, screen_height-self.pageView.frame.origin.y-footerHeightView-20);
    
    
    self.footerView.frame = CGRectMake(0,screen_height-footerHeightView-50, SCREEN_WIDTH_PORTRAIT, footerHeightView); // the player always is bottom
    self.footerView.backgroundColor = [UIColor clearColor];
    
    
    self.view2.frame =CGRectMake(self.view2.frame.origin.x, self.view2.frame.origin.y, SCREEN_WIDTH_PORTRAIT, self.pageView.frame.size.height-heightOfPagingCircle);
    
    
    self.tblView.frame = CGRectMake(self.view2.frame.origin.x, self.view2.frame.origin.y + heightOfPagingCircle, SCREEN_WIDTH_PORTRAIT, self.view2.frame.size.height-heightOfPagingCircle);
    
    
    _view1.frame =_view2.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    

    gMP3Player.index = self.index;
    gMP3Player.song = gMP3Player.song;
    gMP3Player.songArr = self.songArr;
//    [[DatabaseManager defaultDatabaseManager]deletePlaylistwithName:CURRENT_PLAYLIST];
//    for (Song *s in gMP3Player.songArr) {
//        [[DatabaseManager defaultDatabaseManager]insertSong:s andPlaylist:CURRENT_PLAYLIST];
//        
//    }
    [Util setObject:gMP3Player.song.songId forKey:CURRENT_SONG_ID_KEY];
    gMP3Player.nameLbl.text = gMP3Player.song.name;
    gMP3Player.artistLbl.text = gMP3Player.song.desc;
    gMP3Player.view.hidden = NO;
    
    [bannerTimer invalidate];
}

-(void)playInThread{
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(play) object:nil];
    [thread start];
}

-(void)play{
//    [MBProgressHUD showHUDAddedTo: self.view animated:YES];
    if ([gMP3Player.song.songId isEqualToString: currentAudio]) {
        float currentTimeInSecond = CMTimeGetSeconds([_audioPlayer currentTime]);
        [self.slider setValue:currentTimeInSecond/audioDurationInSecond];
        [self fillSongInfo];
        
        self.playBtn.selected = NO;
        [self onPlay:nil];
    }
    else{
        //
        currentAudio = gMP3Player.song.songId;
        [self.slider setValue:0.0f];
        NSURL *urlAudio = [Util getAudioURLForLink:gMP3Player.song.link];
        
        AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:urlAudio options:nil];
        
        CMTime audioDuration = audioAsset.duration;
        
        audioDurationInSecond = CMTimeGetSeconds(audioDuration);
        NSLog(@"Duration :%f",audioDurationInSecond);
        [self fillSongInfo];
        
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:urlAudio];
        if (_audioPlayer.observationInfo) {
            [_audioPlayer removeObserver:self forKeyPath:@"currentItem.status" context:NULL];
        }
        
        _audioPlayer = [[AVPlayer alloc]initWithPlayerItem:item];
        _audioPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[_audioPlayer currentItem]];
        // retain
        [_audioPlayer addObserver:self
                       forKeyPath:@"currentItem.status"
                          options:NSKeyValueObservingOptionNew
                          context:NULL];
        
        self.playBtn.selected = NO;
        [self onPlay:nil];
        [self updateSong];
    }
    [Util setObject:gMP3Player.song.songId forKey:CURRENT_SONG_ID_KEY];
}

-(void) fillSongInfo{
    self.titleLbl.text = gMP3Player.song.name;
    self.songNameLbl.text = gMP3Player.song.name;
    self.artistNameLbl.text = gMP3Player.song.desc;
    self.artistNameLbl.scrollDuration = gMP3Player.song.desc.length;
    
    if (gMP3Player.song.downloadNum.length == 0) {
        gMP3Player.song.downloadNum = @"0";
    }
    if (gMP3Player.song.viewNum.length == 0) {
        gMP3Player.song.viewNum = @"0";
    }
    self.downloadLbl.text = gMP3Player.song.downloadNum;
    self.viewLbl.text = gMP3Player.song.viewNum;


    gMP3Player.nameLbl.text = gMP3Player.song.name;
    gMP3Player.artistLbl.text = gMP3Player.song.desc;
    float currentTimeInSecond = CMTimeGetSeconds([_audioPlayer currentTime]);
    self.currentTimeLbl.text = [Util durationToString:currentTimeInSecond];
    self.totalTimeLbl.text = [Util durationToString:audioDurationInSecond];
    float percenSlider = currentTimeInSecond/audioDurationInSecond;
    _slider.value = percenSlider;
    [self.imgView setImageWithURL:[NSURL URLWithString:gMP3Player.song.image] placeholderImage:[UIImage imageNamed:@"icon_bg.png"]];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"btn_play_new.png"] forState:UIControlStateNormal];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    NSLog(@"Deleting pose");
    [self deleteRecord:currentAudio];
    //    AVPlayerItem *p = [notification object];
    //    [p seekToTime:kCMTimeZero];
}

-(void)OnAddSong:(NSString *)name{
    if ([[DatabaseManager defaultDatabaseManager]getSongwithID:gMP3Player.song.songId Playlist:name].count > 0) {
        [Util showMessage:@"Already in the playlist" withTitle:APP_NAME];
        return;
    }

    [[DatabaseManager defaultDatabaseManager]insertSong:gMP3Player.song andPlaylist:name];
    NSString * err = [Util objectForKey:@"errorsql"];
    if (err.length>0) {
        [Util showMessage:@"Already in the playlist" withTitle:APP_NAME];
    }else{
        [Util showMessage:@"Add PlayList Success" withTitle:APP_NAME];
    }
    [self onCancel];
    
    if ([self respondsToSelector:@selector(onDownload:)]) {
        [self performSelectorOnMainThread:@selector(onDownload:) withObject:nil waitUntilDone:nil];
    }
    
}

-(void)OnDownloadSong{
    if ([[DatabaseManager defaultDatabaseManager]getDownloadedSongwithID:gMP3Player.song.songId].count > 0) {
        [Util showMessage:ALERT_ALREADY_DOWNLOADED withTitle:APP_NAME];
        return;
    }
    
    [[DatabaseManager defaultDatabaseManager]downloadSong:gMP3Player.song];
    NSString * err = [Util objectForKey:@"errorsql"];
    if (err.length>0) {
        [Util showMessage:ALERT_TRY_AGAIN withTitle:APP_NAME];
    }else{
        [Util showMessage:ALERT_FILE_DOWNLOADED withTitle:APP_NAME];
    }
    [self onCancel];
    
}

-(void)onCancel{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

-(void)updateSilder
{
    float currentTimeInSecond = CMTimeGetSeconds([_audioPlayer currentTime]);
    
    if (currentTimeInSecond<0) {
        currentTimeInSecond = 0;
    }

    if (currentTimeInSecond>0) {
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }

    float percenSlider = currentTimeInSecond/audioDurationInSecond;
    


    if (currentTimeInSecond>=audioDurationInSecond) {
        NSLog(@"onNext");
        [self deleteRecord:currentAudio];
       
          // Offline data
       if (_isPushFromMyDownloadScreen == true) {
          self.songArr = [[DatabaseManager defaultDatabaseManager]getDownloadedSongwithID:nil];
          [self.tblView reloadData];
       }
       
         [self onNext:_nextBtn];
    }
    
    self.currentTimeLbl.text = [Util durationToString:currentTimeInSecond];
    _slider.value = percenSlider;
    //    NSLog(@"update %.2f",percenSlider);
    
    
}

- (void) hightLightSongAtIndex:(int) index{
//    <bug2> remove
//    //NSLog(@"hightLight: %d", index);
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//    [self.tblView selectRowAtIndexPath:indexPath
//                              animated:YES
//                        scrollPosition:UITableViewScrollPositionMiddle];
//    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(reloadTableview) object:nil];
//    [thread start];
//    </bug2>
}

-(float)getCurrentProgress{
    
    CMTime duration = _audioPlayer.currentItem.asset.duration;
    float seconds = CMTimeGetSeconds(duration);
    
    float currentTime = CMTimeGetSeconds([_audioPlayer currentTime]);
    
    return currentTime/seconds;
}

- (IBAction)onAddPlayList:(id)sender {
    ShowPlayListViewController *create = [[ShowPlayListViewController alloc]initWithNibName:@"ShowPlayListViewController" bundle:nil];
    create.delegate = self;
    [self presentPopupViewController:create animationType:MJPopupViewAnimationFade];
}

- (IBAction)onDownload:(id)sender {
    if ([[DatabaseManager defaultDatabaseManager]getDownloadedSongwithID:gMP3Player.song.songId].count > 0) {
        [Util showMessage:@"You have downloaded this audio." withTitle:APP_NAME];
    }
    else{
        if (![DELEGATE isConnected]) {
            [Util showMessage:ALERT_TURN_ON_DATA withTitle:ALERT_MOBILE_DATA_OFF];
        } else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeAnnularDeterminate;
            hud.labelText = @"Downloading...    ";
            
//            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            NSURL* url = [NSURL URLWithString:gMP3Player.song.link];
            __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            __weak ASIHTTPRequest *request_ = request;
//            [request setDownloadProgressDelegate:self];
            
            __block float progress = 0;
            
            [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
                progress = progress + ((float)size/(float)total);
                NSLog(@"%f",progress);
                hud.progress = progress;
            }];
            
            [request setCompletionBlock:^{
                NSData* data = [request_ responseData];
                if ( data )
                {
                   //Create audio directory if not exist
                    NSString *dataPath = [Util getAudioDirectoryPath];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
                        NSError *error;
                        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
                    }
                    
                    
                    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", dataPath,[gMP3Player.song.link lastPathComponent]];
                    [data writeToFile:filePath atomically:YES];
                    [Util setObject:filePath forKey:[NSString stringWithFormat:@"%@_localFile",gMP3Player.song.songId]];
                    gMP3Player.song.localMP3 = filePath;
                    HUD.mode = MBProgressHUDModeCustomView;
                    
                    [hud hide:YES];
                    [self OnDownloadSong];
//                    [Util showMessage:@"" withTitle:ALERT_FILE_DOWNLOADED];
                    
                    [ModelManager updateSong:gMP3Player.song.songId path:DOWNLOAD_SONG WithSuccess:^(NSDictionary *dic) {
                        Song *s = [ModelManager parseSongFromDic:dic[@"data"]];
                        [self.imgView setImageWithURL:[NSURL URLWithString:gMP3Player.song.image] placeholderImage:[UIImage imageNamed:@"icon_bg.png"]];
                        gMP3Player.song.viewNum = s.viewNum;
                        gMP3Player.song.downloadNum = s.downloadNum;
                        [self.songArr replaceObjectAtIndex:self.index withObject:gMP3Player.song];
                        self.viewLbl.text = [NSString stringWithFormat:@"%d",[gMP3Player.song.viewNum intValue]];
                        self.downloadLbl.text = [NSString stringWithFormat:@"%d",[gMP3Player.song.downloadNum intValue]];
                        
                        
                        //                    NSDictionary *songDic = dic[@"data"];
                        //                    self.downloadLbl.text = [Validator getSafeString:songDic[@"download"]];
                    } failure:^(NSString *err) {
                        [hud hide:YES];
                    }];
                }
                
                
            }];
            
            [request setFailedBlock:^{
                NSLog(@"error");
                HUD.labelText = @"Download error";
                [hud hide:YES];
                [Util showMessage:@"" withTitle:ALERT_FILE_DOWNLOAD_FAILED];
                
            }];
            [request startAsynchronous];
        }
    }
    
}
- (void)setProgress:(float)progress
{
    [HUD setProgress:progress];
}

- (IBAction)onSlider:(id)sender {
    float value = _slider.value;

    self.currentTimeLbl.text = [Util durationToString:value*audioDurationInSecond];
    if(_audioPlayer)
    {
        CMTime newTime = CMTimeMakeWithSeconds(value*audioDurationInSecond,1);
        [_updateTimer invalidate];
        [_audioPlayer seekToTime:newTime completionHandler:^(BOOL finished) {
            if(finished)
            {
                [_audioPlayer pause];
                [_audioPlayer play];
                [_updateTimer invalidate];
                _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSilder) userInfo:nil repeats:YES];
            }
        }];
    }
}

- (IBAction)onShuffle:(id)sender {
    _isShuffer = !_isShuffer;
    [self setShuffleBtn];
}

- (IBAction)onPrevious:(id)sender {
    [self saveCurrenttTime:currentAudio];
    if (_isShuffer && !_isRepeat) {
        self.index =arc4random_uniform((int)self.songArr.count);
    }else{
        //if (!_isRepeat)
        if (_isRepeat) {
            self.index = self.index;
            currentAudio = @"";
        }else{
            self.index --;
        }
    }
    
    if (self.index<0) {
        self.index = (int)self.songArr.count -1;
    }
    

    gMP3Player.song = [self.songArr objectAtIndex:self.index];
    self.downloadLbl.text = gMP3Player.song.downloadNum;
    self.viewLbl.text = gMP3Player.song.viewNum;
    gMP3Player.song = gMP3Player.song;
    [Util setObject:gMP3Player.song.songId forKey:CURRENT_SONG_ID_KEY];
    // hightlight the current song on list
    [self.tblView reloadData];
    [self play];

}

- (IBAction)onNext:(id)sender {
    [self saveCurrenttTime:currentAudio];
    if (_isShuffer && !_isRepeat) {
        self.index =arc4random_uniform((int)self.songArr.count);
    }
    else{
        //if (!_isRepeat)
        if (_isRepeat) {
            self.index = self.index;
            currentAudio = @"";
        }else{
            self.index ++;
        }
    }
    if (self.index>=self.songArr.count) {
        self.index = 0;
    }
    
    gMP3Player.song = [self.songArr objectAtIndex:self.index];
    self.downloadLbl.text = gMP3Player.song.downloadNum;
    self.viewLbl.text = gMP3Player.song.viewNum;
    
    gMP3Player.song = gMP3Player.song;
    
    [Util setObject:gMP3Player.song.songId forKey:CURRENT_SONG_ID_KEY];
    // hightlight the current song on list
    [self.tblView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self.tblView reloadData];
    [self play];
    

}
-(void)updateSong{
    [ModelManager updateSong:gMP3Player.song.songId path:@"listenSong" WithSuccess:^(NSDictionary *dic){
        Song *s = [ModelManager parseSongFromDic:dic[@"data"]];
        [self.imgView setImageWithURL:[NSURL URLWithString:gMP3Player.song.image] placeholderImage:[UIImage imageNamed:@"icon_bg.png"]];
        gMP3Player.song.viewNum = s.viewNum;
        gMP3Player.song.downloadNum = s.downloadNum;
        [self.songArr replaceObjectAtIndex:self.index withObject:gMP3Player.song];
        self.viewLbl.text = [NSString stringWithFormat:@"%d",[gMP3Player.song.viewNum intValue]];
        
    } failure:^(NSString *err) {
        
    }];
}
- (IBAction)onPlay:(id)sender {
    _isPlaying = _playBtn.selected;
    _playBtn.selected = !_playBtn.selected;
    
    if(_playBtn.selected)
    {
        [_audioPlayer play];
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"btn_pause_new.png"] forState:UIControlStateNormal];
        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSilder) userInfo:nil repeats:YES];
    }else
    {
        [_audioPlayer pause];
        [self saveCurrenttTime:currentAudio];
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"btn_play_new.png"] forState:UIControlStateNormal];
        [_updateTimer invalidate];
        _updateTimer = nil;
    }
    [gMP3Player onPlayPause:nil];
}

- (IBAction)onRightAction:(id)sender {
    UIButton *button1=[UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setFrame:CGRectMake(SCREEN_WIDTH_PORTRAIT-130, 35, 120.0, 30.0)];
    if(dropDown == nil) {
        backgroundLabel.hidden = NO;
        CGFloat f = 120;
        
        dropDown = [[NIDropDown alloc]showDropDown:button1 :&f :[NSMutableArray arrayWithArray:@[@"Add PlayList", @"Share", @"Download"]] :nil :@"down"];
        [self.view addSubview:dropDown];
        [self.view bringSubviewToFront:dropDown];
        dropDown.delegate = self;
    }
    else {
        backgroundLabel.hidden = YES;
        [dropDown hideDropDown:button1];
        [self rel];
    }
}
-(IBAction)onShowDropdown:(id)sender{
    
    [dropDown hideDropDown:nil];
    dropDown = nil;
}
- (void)niDropDownDelegateMethod:(NIDropDown *)sender{
    
    [self.tblView reloadData];
    dropDown = nil;
    
    switch (sender.indexPath.row) {
            
        case 0:
            [self onAddPlayList:nil];

            break;
        case 1:
            [self onShare:nil];

            break;
        case 2:
            [self onDownload:nil];
            break;
        default:
            break;
    }
}
-(void)rel{
    dropDown = nil;
}


- (IBAction)onRepeat:(id)sender {
    _isRepeat = !_isRepeat;
    [self setRepeatBtn];
}
-(void)setRepeatBtn{
    if (_isRepeat) {
        [self.repeatBtn setBackgroundImage:[UIImage imageNamed:@"btn_repeat_on.png"] forState:UIControlStateNormal];
    }
    else{
        [self.repeatBtn setBackgroundImage:[UIImage imageNamed:@"btn_repeat_off.png"] forState:UIControlStateNormal];
    }
}
-(void)setShuffleBtn{
    if (_isShuffer) {
        [_shuffleBtn setBackgroundImage:[UIImage imageNamed:@"btn_shuffle_on.png"] forState:UIControlStateNormal];
    }
    else{
        [_shuffleBtn setBackgroundImage:[UIImage imageNamed:@"btn_shuffle_off.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)onBack:(id)sender {
    //    [_audioPlayer pause];
    //    [_updateTimer invalidate];
    if (self.isFromPush) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        _updateTimer = nil;
        [self.navigationController popViewControllerAnimated:YES];

    }
 }

- (IBAction)onShare:(id)sender {
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    [sharingItems addObject:gMP3Player.song.link];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.songArr.count;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 57;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tblView deselectRowAtIndexPath:indexPath animated:NO];
    
    TopSongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopSongCell"];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TopSongCell" owner:nil options:nil] objectAtIndex:0];
        
       
    }
    Song *s = [self.songArr objectAtIndex:indexPath.row];
    
    cell.nameLbl.text = s.name;
    

    cell.artistLbl.text = s.desc;
    
    cell.nameLbl.textColor = [UIColor blackColor];
    
    cell.artistLbl.textColor = [Util colorFromHexString:@"#3e4a43" andAlpha:1];
    
    cell.separatorLbl.backgroundColor =[Util colorFromHexString:@"#32586d" andAlpha:0.5];
    if (indexPath.row == self.index){
        
        [cell setBackgroundColor:[Util colorFromHexString:@"#b7b6b5" andAlpha:0.5]];
    }
    else
        [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"%ld",(long)indexPath.row);
    NSLog(@"%@", [[songArr objectAtIndex:indexPath.row] description]);
    
    gMP3Player.song = [self.songArr objectAtIndex:indexPath.row];
    self.index = (int)indexPath.row;
    [self hightLightSongAtIndex: self.index];
    [self play];
    [self.tblView reloadData];
}

-(void)reloadTableview{
    [self.tblView reloadData];
}

#pragma mark - Time presistance layer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    
    NSLog(@"Key observed");
    switch (_audioPlayer.status) {
        case AVPlayerItemStatusReadyToPlay:
            NSLog(@"Normal playback");
            [self retainPlayTime];
            [self updateSong];
            [_audioPlayer pause];
            [_audioPlayer play];
            break;
        default:
            break;
    }
}


-(void)retainPlayTime
{
    if (_audioPlayer.observationInfo) {
        [_audioPlayer removeObserver:self forKeyPath:@"currentItem.status" context:NULL];
    }
    NSLog(@"Retained");
    CMTime toAdvance = [self loadCurrentTimeWithKey:currentAudio];
    
    if CMTIME_IS_VALID(toAdvance) {
        Float32 floatTime = CMTimeGetSeconds(toAdvance);
        NSLog(@"Time %f", floatTime);
        if (floatTime > 1) {
            float percenSlider = floatTime/audioDurationInSecond;
            [self.slider setValue:percenSlider animated:true];
            
            int32_t timeScale = _audioPlayer.currentItem.asset.duration.timescale;
            CMTime time = CMTimeMakeWithSeconds(floatTime, timeScale);
            [_audioPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
//            [self onSlider:nil];
            NSLog(@"Retained success");
        }
    }
}

-(void)deleteRecord:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
}

- (void)saveCurrenttTime:(NSString *)key {
    NSLog(@"Saving time");
    CMTime cmTime = _audioPlayer.currentTime;
    if (cmTime.value != 0) {
        NSLog(@"Time saved %lld", cmTime.value);
        CFDictionaryRef timeAsDictionary = CMTimeCopyAsDictionary(cmTime, kCFAllocatorDefault);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:(__bridge id _Nullable)(timeAsDictionary) forKey:key];
        [defaults synchronize];
    }
}

- (CMTime)loadCurrentTimeWithKey:(NSString *)key {
    NSLog(@"loading saved time");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CFDictionaryRef encodedObject = (__bridge CFDictionaryRef)([defaults objectForKey:key]);
    CMTime object = CMTimeMakeFromDictionary(encodedObject);
    return object;
}


@end
