//
//  PlaySongViewController.h
//  PTMusicApp
//
//  Created by hieu nguyen on 12/20/14.
//  Copyright (c) 2014 Fruity Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Song.h"
#import "MarqueeLabel.h"
#import "NIDropDown.h"
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
@interface PlaySongViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NIDropDownDelegate,UINavigationControllerDelegate>{
    NSTimer* _updateTimer;
    NIDropDown *dropDown;
    MBProgressHUD *HUD;
    UILabel *backgroundLabel;
}

@property (nonatomic, assign) BOOL isFromPush;
@property (nonatomic, assign) BOOL isPushFromMyDownloadScreen;


@property (strong, nonatomic) NSMutableArray *songArr;

@property (weak, nonatomic) IBOutlet UIButton *downloadIcon;
@property (weak, nonatomic) IBOutlet UIButton *noOfViewIcon;
@property int index;
@property BOOL pauseOnLoad;

@property (strong, nonatomic) IBOutlet UIView *view1;
@property (strong, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIScrollView *pageView;


@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
- (IBAction)onBack:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLbl;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *repeatBtn;

@property (weak, nonatomic) IBOutlet UIButton *previousBtn;
@property (weak, nonatomic) IBOutlet UIButton *shuffleBtn;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *downloadLbl;
@property (weak, nonatomic) IBOutlet UILabel *viewLbl;

@property (weak, nonatomic) IBOutlet MarqueeLabel *songNameLbl;
@property (weak, nonatomic) IBOutlet MarqueeLabel *artistNameLbl;

- (IBAction)onRepeat:(id)sender;


- (IBAction)onSlider:(id)sender;
- (IBAction)onShuffle:(id)sender;
- (IBAction)onPrevious:(id)sender;
- (IBAction)onNext:(id)sender;
- (IBAction)onPlay:(id)sender;
- (IBAction)onRightAction:(id)sender;

- (void)saveCurrenttTime:(NSString *)key;
@end
