//
//  PlaylistViewController.m
//  PTMusicApp
//
//  Created by hieu nguyen on 12/6/14.
//  Copyright (c) 2014 Fruity Solution. All rights reserved.
//

#import "PlaylistViewController.h"
#import "SWRevealViewController.h"
#import "DatabaseManager.h"
#import "PlaySongViewController.h"
#import "CreatePlaylistViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "DatabaseManager.h"
#import "ListSongViewController.h"
#import "TopSongViewController.h"
#import "Common.h"
#import "AsyncImageView.h"
#import "WebViewController.h"
#import "CustomButton.h"
#import "BannerItem.h"

#import "ModelManager.h"
#import "Validator.h"

@interface PlaylistViewController ()<CreatePlaylistViewControllerDelegate,ListSongViewControllerDelegate,MP3PlayerDelegate>

@end

@implementation PlaylistViewController{
    NSArray *arrayBanner;
    UIImageView *imgVBanner;
    UIView *viewBanner ;
    CustomButton *btnBanner;
    
    NSTimer *bannerTimer;
}


-(void)createBanner{
    
    viewBanner = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                          SCREEN_HEIGHT_PORTRAIT -50,
                                                          SCREEN_WIDTH_PORTRAIT,
                                                          50)];
    viewBanner.backgroundColor = [UIColor clearColor];
    [self.view addSubview:viewBanner];
    [self.view bringSubviewToFront:viewBanner];
    [self.view bringSubviewToFront:_revealBtn];
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

-(int)randomFromZeroTo:(int)number{
    return arc4random_uniform(number);
}

-(void)changeBanner{
    NSLog(@"change Banner");
    if (arrayBanner.count > 0) {
        int index = [self randomFromZeroTo:arrayBanner.count];
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



- (void)viewDidLoad {
    [super viewDidLoad];

    [self createBanner];
    
    [self setRevealBtn];
    [self.tblView setBackgroundColor:[UIColor clearColor]];
    
    self.playlistArr = [[NSMutableArray alloc]init];
    self.playlistArr =  [[DatabaseManager defaultDatabaseManager]getAllPlaylist];
    //    for (NSString *name in self.playlistArr) {
    //        NSMutableArray *songArr = [[DatabaseManager defaultDatabaseManager]getAllSongwithPlaylist:name];
    //        if (songArr.count == 0) {
    //            [self.playlistArr removeObject:name];
    //            [[DatabaseManager defaultDatabaseManager]deletePlaylist:name];
    //        }
    //    }
    // Do any additional setup after loading the view from its nib.
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.2; //seconds
    lpgr.delegate = self;
    [self.tblView addGestureRecognizer:lpgr];
    self.tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}



-(void)NextDetailWithSongArr:(NSMutableArray *)songarr andInde:(int)index{
    PlaySongViewController *play = [[PlaySongViewController alloc]initWithNibName:@"PlaySongViewController" bundle:nil];
    play.songArr = songarr;
    play.songIndex = index;
    play.pauseOnLoad = ![Util isMusicPlaying];
    [self.navigationController pushViewController:play animated:YES];
    
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tblView];
    
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press on table view at row %ld", (long)indexPath.row);
        self.nameList = [self.playlistArr objectAtIndex:indexPath.row];
        [Util showMessage:LANG_REMOVE_PLAYLIST withTitle:APP_NAME andDelegate:self];
       
            } else {
        NSLog(@"gestureRecognizer.state = %ld", gestureRecognizer.state);
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        [[DatabaseManager defaultDatabaseManager]deleteSongListPlaywithName:self.nameList]; // delete the playlist
        [[DatabaseManager defaultDatabaseManager]deleteAllSongsOfPlaylistWithName:self.nameList]; // delete songs of that playlist
        [self.playlistArr removeAllObjects];
        self.playlistArr =  [[DatabaseManager defaultDatabaseManager]getAllPlaylist];
        [self.tblView reloadData];
    }
}

-(void)targetMethod{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setRevealBtn{
    SWRevealViewController *revealController = self.revealViewController;
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    [_revealBtn addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)viewWillAppear:(BOOL)animated{
    keyboard = [[UIKeyboardViewController alloc]initWithControllerDelegate:self];
    keyboard.isShowButton = 100;
    [keyboard addToolbarToKeyboard];
    gMP3Player.view.frame = CGRectMake(0, viewBanner.frame.origin.y - 50, self.view.frame.size.width, 50);
    [self.view addSubview: gMP3Player.view];
    gMP3Player.delegate = self;
    [self.tblView reloadData];
 
    if (gMP3Player.song.songId.length>0) {
        self.tblView.frame = CGRectMake(self.tblView.frame.origin.x, self.tblView.frame.origin.y, self.tblView.frame.size.width, gMP3Player.view.frame.origin.y-self.tblView.frame.origin.y);
    }
    else{
        self.tblView.frame = CGRectMake(self.tblView.frame.origin.x, self.tblView.frame.origin.y, self.tblView.frame.size.width, self.view.frame.size.height-self.tblView.frame.origin.y);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [bannerTimer invalidate];
}

- (IBAction)onCreate:(id)sender {
    CreatePlaylistViewController *create = [[CreatePlaylistViewController alloc]initWithNibName:@"CreatePlaylistViewController" bundle:nil];
    create.delegate = self;
    [self presentPopupViewController:create animationType:MJPopupViewAnimationFade];
    
}

-(void)onCreatePlaylist:(NSString *)name{
    if ([[DatabaseManager defaultDatabaseManager]getPlaylistWithName:name].count > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Playlist Exist"  ] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        
        [self onCancel];
        
        return;
    }
    
    [[DatabaseManager defaultDatabaseManager]insertPlaylist:name];
    [self onCancel];
    [[DatabaseManager defaultDatabaseManager]activePlaylist:name];
    self.playlistArr =  [[DatabaseManager defaultDatabaseManager]getAllPlaylist];
    [self.tblView reloadData];
//    ListSongViewController *list = [[ListSongViewController alloc]initWithNibName:@"ListSongViewController" bundle:nil];
//    list.delegate = self;
//    list.playlist = name;
//    [self.navigationController pushViewController:list animated:YES];
}
-(void)onDone{
    self.playlistArr =  [[DatabaseManager defaultDatabaseManager]getAllPlaylist];
    [self.tblView reloadData];
}
-(void)onCancel{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
//     self.playlistArr =  [[DatabaseManager defaultDatabaseManager]getAllPlaylist];
//     [self.tblView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.playlistArr.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSString *name = [self.playlistArr objectAtIndex:indexPath.row];
    
    cell.textLabel.text = name;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
//    longPressGesture.minimumPressDuration = 1.0;
//    [self.mapView addGestureRecognizer:longPressGesture];
    _isPlayList = TRUE;
    TopSongViewController *song = [[TopSongViewController alloc]initWithNibName:@"TopSongViewController" bundle:nil];
    song.songArr = [[DatabaseManager defaultDatabaseManager]getAllSongwithPlaylist:[self.playlistArr objectAtIndex:indexPath.row]];
    song.name = [self.playlistArr objectAtIndex:indexPath.row];
    song.checkview = YES;
    _isTopSong = YES;
    song.fromWhichView = VIEW_PLAY_LIST;
    [self.navigationController pushViewController:song animated:YES];
}

@end
