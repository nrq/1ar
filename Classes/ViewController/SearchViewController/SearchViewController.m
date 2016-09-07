//
//  SearchViewController.m
//  PTMusicApp
//
//  Created by hieu nguyen on 12/6/14.
//  Copyright (c) 2014 Fruity Solution. All rights reserved.
//

#import "SearchViewController.h"
#import "SWRevealViewController.h"
#import "ModelManager.h"
#import "MBProgressHUD.h"
#import "TopSongCell.h"
#import "PlaySongViewController.h"
#import "AsyncImageView.h"
#import "WebViewController.h"
#import "CustomButton.h"
#import "BannerItem.h"
#import "AppDelegate.h"

@interface SearchViewController ()<MP3PlayerDelegate>

@end

@implementation SearchViewController{
    NSArray *arrayBanner;
    UIImageView *imgVBanner;
    UIView *viewBanner ;
    CustomButton *btnBanner;
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
//    imgVBanner.contentMode = UIViewContentModeScaleAspectFit;
    
    [viewBanner addSubview:imgVBanner];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ModelManager getBannerWithType:@"0" WithSuccess:^(NSArray *arr) {
            arrayBanner = arr;
            
            int index = [self randomFromZeroTo:arrayBanner.count];
            BannerItem *b = arr[index];
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
    currentPage = 1;
    self.songArr = [[NSMutableArray alloc]init];
    [_tblView setDragDelegate:self refreshDatePermanentKey:@"SongList"];
    _tblView.showLoadMoreView = YES;
    
    [self setRevealBtn];
    self.tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tblView setBackgroundColor:[UIColor clearColor]];
    
    // Do any additional setup after loading the view from its nib.
    
    [self createBanner];

//    if (!(gMP3Player.song.songId.length>0)) {
//        [self createBanner];
//    }else{
//        
//    }
    
}

- (IBAction)menuToggle:(id)sender {
    [self.searchBar resignFirstResponder];

}

-(void)NextDetailWithSongArr:(NSMutableArray *)songarr andInde:(int)index{
    PlaySongViewController *play = [[PlaySongViewController alloc]initWithNibName:@"PlaySongViewController" bundle:nil];
    play.songArr = songarr;
    play.songIndex = index;
    play.pauseOnLoad = ![Util isMusicPlaying];
    [self.navigationController pushViewController:play animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    
    gMP3Player.view.frame = CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 50);
    [self.view addSubview: gMP3Player.view];
    gMP3Player.delegate = self;
    
    if (gMP3Player.song.songId.length>0) {
        self.tblView.frame = CGRectMake(self.tblView.frame.origin.x, self.tblView.frame.origin.y, self.tblView.frame.size.width, self.view.frame.size.height-self.tblView.frame.origin.y - 100);
    }
    else{
        self.tblView.frame = CGRectMake(self.tblView.frame.origin.x, self.tblView.frame.origin.y, self.tblView.frame.size.width, self.view.frame.size.height-self.tblView.frame.origin.y - 50);
    }
}
-(void)setRevealBtn{
    SWRevealViewController *revealController = self.revealViewController;
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    [_revealBtn addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];

    
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    [self.songArr removeAllObjects];
    [self searchWithKey:self.searchBar.text];
}
-(void)searchWithKey:(NSString *)key{
    if (![DELEGATE isConnected]) {
        [Util showMessage:ALERT_TURN_ON_DATA withTitle:ALERT_MOBILE_DATA_OFF];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [ModelManager searchSongBykey:key page:currentPage WithSuccess:^(NSMutableArray *arr) {
            [self.songArr addObjectsFromArray:arr];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tblView reloadData];
            [_tblView finishRefresh];
            [_tblView finishLoadMore];
        } failure:^(NSString *err) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [_tblView finishRefresh];
            [_tblView finishLoadMore];
        }];
    }
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
        if (indexPath.row >= self.songArr.count){
            return cell;
        }
        Song *s = [self.songArr objectAtIndex:indexPath.row];
        cell.nameLbl.text = s.name;
        cell.artistLbl.text = s.desc;
    }
    
    if (indexPath.row%2==0) {
        UIImageView *img = [[UIImageView alloc]initWithFrame:cell.frame];
        img.image = [UIImage imageNamed:@"bg_item_song.png"];
        [cell setBackgroundView:img];
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
    PlaySongViewController *play = [[PlaySongViewController alloc]initWithNibName:@"PlaySongViewController" bundle:nil];
    play.songArr = self.songArr;
    play.songIndex = indexPath.row;
    [self.navigationController pushViewController:play animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [bannerTimer invalidate];
    
}


#pragma mark - Drag delegate methods

- (void)dragTableDidTriggerRefresh:(UITableView *)tableView
{
    
    [self.songArr removeAllObjects];

    currentPage = 1;
    
    [self searchWithKey:self.searchBar.text];
    
}

- (void)dragTableRefreshCanceled:(UITableView *)tableView
{

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishRefresh) object:nil];
}

- (void)dragTableDidTriggerLoadMore:(UITableView *)tableView{

    currentPage++;
    
    [self searchWithKey:self.searchBar.text];
}


- (void)dragTableLoadMoreCanceled:(UITableView *)tableView{
    
}



@end
