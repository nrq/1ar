//
//  TopSongViewController.m
//  PTMusicApp
//
//  Created by hieu nguyen on 12/6/14.
//  Copyright (c) 2014 Fruity Solution. All rights reserved.
//

#import "TopSongViewController.h"
#import "TopSongCell.h"
#import "Song.h"
#import "SWRevealViewController.h"
#import "MBProgressHUD.h"
#import "ModelManager.h"
#import "PlaySongViewController.h"
#import "UITableView+DragLoad.h"
#import "UIView+Toast.h"
#import "DatabaseManager.h"
#import "AsyncImageView.h"
#import "WebViewController.h"
#import "CustomButton.h"
#import "BannerItem.h"
#import "AppDelegate.h"

@interface TopSongViewController ()<UITableViewDragLoadDelegate, UIGestureRecognizerDelegate,SWRevealViewControllerDelegate>
{
    int page;
}
@end

@implementation TopSongViewController
{
    NSArray *arrayBanner;
    UIImageView *imgVBanner;
    UIView *viewBanner ;
    CustomButton *btnBanner;
    
    NSString* selectedPlaylist;
    NSString* selectedSongID;
    
    NSTimer *bannerTimer;
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
        [ModelManager  getBannerWithType:@"0" WithSuccess:^(NSArray *arr) {
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
    [self setupTableHeight];
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


-(void)closeMenu{
    
    UIButton *button1=[UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setFrame:CGRectMake(SCREEN_WIDTH_PORTRAIT-150, 35, 140.0, 30.0)];
    if(dropDown == nil) {}
    else {
        [dropDown hideDropDown:button1];
        [self rel];
    }
}

-(NSArray *)listFileAtAudioDir
{
    //-----> LIST ALL FILES <-----//
    NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[Util getAudioDirectoryPath] error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}

-(NSMutableArray *)getDownloadedAudio{
    return [[DatabaseManager defaultDatabaseManager]getDownloadedSongwithID:nil];
    
}

- (NSMutableArray *)getDownloadedAudioAndReloadData{
    NSMutableArray *downloadedAudio = [self getDownloadedAudio];
    
    self.songArr = downloadedAudio;
    
    [UIView transitionWithView: self.tblView
                      duration: 0.35f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^(void)
     {
         [self.tblView reloadData];
     }
                    completion: nil];
    
    return downloadedAudio;
}

#pragma mark - SWRevealViewControllerDelegate

- (BOOL)revealControllerPanGestureShouldBegin:(SWRevealViewController *)revealController
{
    float velocity = [revealController.panGestureRecognizer velocityInView:self.view].x;
    if (velocity < 0 && self.revealViewController.frontViewPosition == FrontViewPositionLeft)
        return NO;
    else
        return YES;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)];
    tapGesture.delegate = self;
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    self.titleLbl.font = [UIFont boldSystemFontOfSize:17];
    self.titleLbl.textColor = [UIColor whiteColor];
    self.titleLbl.textAlignment = NSTextAlignmentCenter;
    if (self.songArr.count==0) {
        self.songArr = [[NSMutableArray alloc]init];
    }
    
    page = 1;
    
    if (self.fromWhichView == VIEW_MY_DOWNLOAD){
        
        NSMutableArray *downloadedAudio = [self getDownloadedAudioAndReloadData];
        
        if (downloadedAudio.count == 0){
            [Util showMessage:ALERT_ALREADY_NO_DOWNLOADED_FILES withTitle:APP_NAME];
        }
        
        self.titleLbl.text = MENU_MY_DOWNLOAD;
        self.btnSort.hidden = YES;
        _tblView.showLoadMoreView = NO;
        
        [self listFileAtAudioDir];
    }else{
        if (_isTopSong) {
            self.titleLbl.text = @"Most Favorite";
            self.btnSort.hidden = YES;
            
            [_tblView setDragDelegate:self refreshDatePermanentKey:@"SongList"];
            _tblView.showLoadMoreView = YES;
        }
        else{
            if (![DELEGATE isConnected]) {
                
            } else {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            }
            
            self.titleLbl.text = @"Latest";
            
            [_tblView setDragDelegate:self refreshDatePermanentKey:@"SongList"];
            _tblView.showLoadMoreView = YES;
            _tblView.separatorColor = [UIColor clearColor];
            self.btnSort.hidden = NO;
        }
    }
    
    self.titleLbl.fadeLength = 10;
    
    if (self.songArr.count == 0 && !self.album && !self.category) {
        if (self.checkview == YES) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.revealBtn setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
            
            self.revealBtn.frame = CGRectMake(self.revealBtn.frame.origin.x, self.revealBtn.frame.origin.y, 50, 50);
            [self.revealBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
            if (self.name) {
                self.titleLbl.text = self.name;
            }
            if (self.album) {
                [self getDataWithAlbum];
                self.titleLbl.text = self.album.name;
            }
            else{
                if (self.category) {
                    [self getDataWithCategory];
                    self.titleLbl.text = self.category.name;
                }
            }
            
        }else{
            [self setRevealBtn];
            
            if (self.fromWhichView == VIEW_MY_DOWNLOAD){
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getDownloadedAudioAndReloadData) userInfo:nil repeats:NO];
            }else{
                if ([DELEGATE isConnected]) {
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                }
                if (_isTopSong) {
                    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getData) userInfo:nil repeats:NO];
                }
                else{
                    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getDataAllSong) userInfo:nil repeats:NO];
                }
            }
        }
    }
    else{
        
        if (self.fromWhichView != VIEW_MY_DOWNLOAD){
            [self.revealBtn setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
            
            self.revealBtn.frame = CGRectMake(self.revealBtn.frame.origin.x, self.revealBtn.frame.origin.y, 50, 50);
            [self.revealBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
            if (self.name) {
                self.titleLbl.text = self.name;
                
            }
            if (self.album) {
                [self getDataWithAlbum];
                self.titleLbl.text = self.album.name;
            }
            else{
                if (self.category) {
                    [self getDataWithCategory];
                    self.titleLbl.text = self.category.name;
                }
            }
        }
        
    }
    
    if (self.fromWhichView == VIEW_PLAY_LIST){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 1.2; //seconds
        lpgr.delegate = self;
        [self.tblView addGestureRecognizer:lpgr];
    }else  if (self.fromWhichView == VIEW_MY_DOWNLOAD){
        [self setRevealBtn];
    }
    [self setTheme];
    
    
    [self createBanner];
    
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tblView];
    
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:p];
    if (indexPath != nil && gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        selectedPlaylist = self.name;
        Song *s = [self.songArr objectAtIndex:indexPath.row];
        selectedSongID= s.songId;
        
        [Util showMessage:LANG_REMOVE_SONG_FROM_PLAYLIST withTitle:APP_NAME andDelegate:self];
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        [[DatabaseManager defaultDatabaseManager] removeSongWith:selectedSongID andPlaylist:selectedPlaylist];
        
        self.songArr = [[DatabaseManager defaultDatabaseManager]getAllSongwithPlaylist:selectedPlaylist];
        [self reloadTableView];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self setupTableHeight];
}
-(void)setupTableHeight{
    gMP3Player.view.frame = CGRectMake(0, viewBanner.frame.origin.y - 50, self.view.frame.size.width, 50);
    [self.view addSubview: gMP3Player.view];
    gMP3Player.delegate = self;
    if (gMP3Player.song == nil){
        self.tblView.frame = CGRectMake(self.tblView.frame.origin.x, self.tblView.frame.origin.y, self.tblView.frame.size.width, viewBanner.frame.origin.y-self.tblView.frame.origin.y);
    }else{
        self.tblView.frame = CGRectMake(self.tblView.frame.origin.x, self.tblView.frame.origin.y, self.tblView.frame.size.width, gMP3Player.view.frame.origin.y-self.tblView.frame.origin.y);
    }
}
-(IBAction)onBack:(id)sender{
    //    [self setRevealBtn];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Control datasource

- (void)finishRefresh
{
    //<bug4> remove
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //    page = 1;
    //
    //    [_tblView finishRefresh];
    //    if (_isTopSong) {
    //        [self getData];
    //
    //    }else{
    //        [self getDataAllSong];
    //    }
    //</bug4>
}

#pragma mark - Drag delegate methods

- (void)dragTableDidTriggerRefresh:(UITableView *)tableView
{
    [self closeMenu];
    if (self.fromWhichView == VIEW_PLAY_LIST){
        [_tblView finishRefresh];
        [_tblView finishLoadMore];
        return;
    }
    
    //send refresh request(generally network request) here
    [self.songArr removeAllObjects];
    //        <bug4> modify
    page = 1;
    
    if (self.album) {
        [self getDataWithAlbum];
        self.titleLbl.text = self.album.name;
    }
    else if (self.category) {
        [self getDataWithCategory];
        self.titleLbl.text = self.category.name;
    }
    else if (_isTopSong) {
        [self getData];
    }
    else{
        if (self.fromWhichView == VIEW_MY_DOWNLOAD){
            [self getDownloadedAudioAndReloadData];
        }else{
            [self getDataAllSong];
        }
    }
    
}

- (void)dragTableRefreshCanceled:(UITableView *)tableView
{
    [self closeMenu];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishRefresh) object:nil];
}

- (void)dragTableDidTriggerLoadMore:(UITableView *)tableView{
    [self closeMenu];
    
    if (self.fromWhichView == VIEW_PLAY_LIST){
        [_tblView finishRefresh];
        [_tblView finishLoadMore];
        return;
    }
    
    page ++;
    if (self.album) {
        [self getDataWithAlbum];
        self.titleLbl.text = self.album.name;
    }
    else if (self.category) {
        [self getDataWithCategory];
        self.titleLbl.text = self.category.name;
    }
    else if (_isTopSong) {
        [self getData];
    }
    else{
        if (self.fromWhichView == VIEW_MY_DOWNLOAD){
            [self getDownloadedAudioAndReloadData];
        }else{
            [self getDataAllSong];
        }
    }
}


- (void)dragTableLoadMoreCanceled:(UITableView *)tableView{
    
}

-(void)getData{
    if ([DELEGATE isConnected]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 5; i++) {

            [ModelManager getListTopSongWithpage:[NSString stringWithFormat:@"%d",page] Success:^(NSMutableArray *arr) {
                if (arr.count>0) {
                    for (Song *s in arr) {
                        [self.songArr addObject:s];
                    }
                }
                else{
                    [self.view makeToast:@"No Data" duration:2.0 position:CSToastPositionCenter];
                }
                [self reloadTableView];
                [self endLoading];
            } failure:^(NSString *err) {
                [self endLoading];
                [self.view makeToast:@"No Data" duration:2.0 position:CSToastPositionCenter];
            }];
            page++;
        }
        
    });
}

-(void)getDataAllSong{
    if ([DELEGATE isConnected]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 5; i++) {

            [ModelManager getListSongWithType:self.typeSong withPage:[NSString stringWithFormat:@"%d",page] WithSuccess:^(NSMutableArray *arr) {
                if (arr.count>0) {
                    for (Song *s in arr) {
                        [self.songArr addObject:s];
                    }
                }
                else{
                    [self.view makeToast:@"No Data" duration:2.0 position:CSToastPositionCenter];
                }
                [self reloadTableView];
                [self endLoading];
            } failure:^(NSString *err) {
                [self endLoading];
                [self.view makeToast:@"No Data" duration:2.0 position:CSToastPositionCenter];
            }];
            page++;
        }
    });
}

-(void)getDataWithAlbum{
    if ([DELEGATE isConnected]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 5; i++) {
            [ModelManager getListSongByAlbumId:self.album.albumId page:page WithSuccess:^(NSMutableArray *arr) {
                // return
                if (arr == (id)[NSNull null] || [arr count] == 0) {
                    [self endLoading];
                    return;
                }
                
                if (page ==1) {
                    [self.songArr removeAllObjects];
                }
                [self.songArr addObjectsFromArray:arr];
                [self reloadTableView];
                [self endLoading];
            } failure:^(NSString *err) {
                [self endLoading];
            }];
            page++;
        }
    });
}


-(void)getDataWithCategory{
    if ([DELEGATE isConnected]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 5; i++) {
            [ModelManager getListSongByCategoryId:self.category.categoryId page:page WithSuccess:^(NSMutableArray *arr) {
                // return
                if (arr == (id)[NSNull null] || [arr count] == 0) {
                    [self endLoading];
                    return;
                }
                if (page ==1) {
                    [self.songArr removeAllObjects];
                }
                [self.songArr addObjectsFromArray:arr];;
                [self reloadTableView];
                [self endLoading];

            } failure:^(NSString *err) {
                [self endLoading];
            }];
            page++;
        }
    });
}

// finish loading tableview data
-(void)endLoading {
    [_tblView finishRefresh];
    [_tblView finishLoadMore];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

}

-(void)setTheme{
    self.tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tblView setBackgroundColor:[UIColor clearColor]];
}

-(void)setRevealBtn{
    SWRevealViewController *revealController = self.revealViewController;
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    [revealController setDelegate:self];
    [_revealBtn addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.songArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 57;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TopSongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopSongCell"];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TopSongCell" owner:nil options:nil] objectAtIndex:0];
        if (indexPath.row>=self.songArr.count) {
            return cell;
        }
        Song *s = [self.songArr objectAtIndex:indexPath.row];
        cell.nameLbl.text = s.name;
        cell.artistLbl.text = s.desc;
    }
    
    if (indexPath.row%2==0) {
        UIImageView *img = [[UIImageView alloc]initWithFrame:cell.frame];
        img.image = [UIImage imageNamed:@"bg_item_song.png"];
        //[cell setBackgroundView:img];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    else{
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row%2==0) {
        UIImageView *img = [[UIImageView alloc]initWithFrame:cell.frame];
        img.image = [UIImage imageNamed:@"bg_item_song.png"];
        [cell setBackgroundView:img];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *myCell = [tableView cellForRowAtIndexPath:indexPath];
    [myCell setSelectionStyle:UITableViewCellSelectionStyleNone]; // disable highlight effect
    Song *s = [self.songArr objectAtIndex:indexPath.row];
    if ([Util isAudioExistForLink:s.link]) {
        [self pushToPlayVCForIndex:indexPath];
    }else{
        if (![DELEGATE isConnected]) {
            [Util showMessage:ALERT_TURN_ON_DATA withTitle:APP_NAME];
        }else{
            [self pushToPlayVCForIndex:indexPath];
        }
    
    }

}

- (void)pushToPlayVCForIndex:(NSIndexPath*)indexPath{
    PlaySongViewController *play = [[PlaySongViewController alloc] initWithNibName:@"PlaySongViewController" bundle:nil];
    play.songArr = self.songArr;
    play.songIndex = (int)indexPath.row;
    play.isPushFromMyDownloadScreen = (self.fromWhichView == VIEW_MY_DOWNLOAD) ? true : false;
    
    [self.navigationController pushViewController:play animated:YES];
    
    [self closeMenu];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if (self.fromWhichView == VIEW_MY_DOWNLOAD){
        return YES;
    }else{
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        if (self.fromWhichView == VIEW_MY_DOWNLOAD){
            [self deleteDownloadedAudioAtIndexPath:indexPath];
        }
    }
}

-(void) deleteDownloadedAudioAtIndexPath:(NSIndexPath *)indexPath{
    Song *s = [self.songArr objectAtIndex:indexPath.row];
    [[DatabaseManager defaultDatabaseManager] deleteDownloadedSongWithSongId:s.songId];
    [Util deleteAudioForLink:s.link];
    
    NSMutableArray *downloadedAudio = [self getDownloadedAudioAndReloadData];
    
    if (downloadedAudio.count == 0){
        [Util showMessage:ALERT_ALREADY_NO_DOWNLOADED_FILES withTitle:APP_NAME];
    }
}

-(void)NextDetailWithSongArr:(NSMutableArray *)songarr andInde:(int)index{
    PlaySongViewController *play = [[PlaySongViewController alloc] initWithNibName:@"PlaySongViewController" bundle:nil];
    play.songArr = songarr;
    play.songIndex = index;
    play.pauseOnLoad = ![Util isMusicPlaying];
    [self.navigationController pushViewController:play animated:YES];
}

- (IBAction)onSort:(id)sender {
    UIButton *button1=[UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setFrame:CGRectMake(SCREEN_WIDTH_PORTRAIT-150, 35, 140.0, 30.0)];
    if(dropDown == nil) {
        
        CGFloat f = 78;
        if (f>158) {
            f = 158;
        }
        dropDown = [[NIDropDown alloc]showDropDown:button1 :&f :[NSMutableArray arrayWithArray:@[@"Sort by Date", @"Sort by Views"]] :nil :@"down"];
        [self.view addSubview:dropDown];
        dropDown.delegate = self;
    }
    else {
        [dropDown hideDropDown:button1];
        [self rel];
    }
}

-(IBAction)onShowDropdown:(id)sender{
    
    [dropDown hideDropDown:nil];
    dropDown = nil;
    
    //    if(dropDown == nil) {
    //        CGFloat f = 160;
    //        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :[Util fakeMenu] :nil :@"down"];
    //        [self.view addSubview:dropDown];
    //        dropDown.delegate = self;
    //    }
    //    else {
    //        [dropDown hideDropDown:sender];
    //        [self rel];
    //    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
    
    dropDown = nil;
    NSString *type = @"";
    switch (sender.indexPath.row) {
        case 0:
            type = @"";
            break;
            //        case 2:
            //            type = @"download";
            //            break;
        case 1:
            type = @"listen";
            break;
        default:
            break;
    }
    self.typeSong = type;
    
    if (![DELEGATE isConnected]) {
        [Util showMessage:ALERT_TURN_ON_DATA withTitle:ALERT_MOBILE_DATA_OFF];
    } else {
        if ([DELEGATE isConnected]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        [ModelManager getListSongWithType:type withPage:[NSString stringWithFormat:@"%d",page] WithSuccess:^(NSMutableArray *arr) {
            [self.songArr removeAllObjects];
            [self.songArr addObjectsFromArray:arr];
            [self reloadTableView];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        } failure:^(NSString *err) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    }
}

-(void)rel{
    dropDown = nil;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [bannerTimer invalidate];
    
    SWRevealViewController *revealController = self.revealViewController;
    [revealController setDelegate:DELEGATE];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self closeMenu];
}

- (void)reloadTableView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tblView reloadData];
    });
}

@end



