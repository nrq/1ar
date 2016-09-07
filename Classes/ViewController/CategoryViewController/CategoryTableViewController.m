//
//  CategoryTableViewController.m
//  PTMusicApp
//
//  Created by tuan vn on 5/3/16.
//  Copyright © 2016 Fruity Solution. All rights reserved.
//

#import "CategoryTableViewController.h"
#import "AsyncImageView.h"
#import "ModelManager.h"
#import "MBProgressHUD.h"
#import "TopSongViewController.h"
#import "PlaySongViewController.h"
#import "UITableView+DragLoad.h"
#import "AppDelegate.h"

@interface CategoryTableViewController ()<UITableViewDelegate, UITableViewDataSource, MP3PlayerDelegate, UITableViewDragLoadDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CategoryTableViewController{
    int currentPage;
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentPage = 1;
    [self.tableView setDragDelegate:self refreshDatePermanentKey:@"SongList"];
    self.tableView.showLoadMoreView = YES;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (![DELEGATE isConnected]) {
        [Util showMessage:ALERT_TURN_ON_DATA withTitle:ALERT_MOBILE_DATA_OFF];
    } else {
        if (self.categories) {
            [self getSubCate];
            [self.lblTitle setText:self.categories.name];
            [self.revealBtn setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
            [self.revealBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
            
        }else{
            [self getData];
            [self setRevealBtn];
            
        }
    }

}

-(void)setRevealBtn{
    SWRevealViewController *revealController = self.revealViewController;
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    [_revealBtn addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)NextDetailWithSongArr:(NSMutableArray *)songarr andInde:(int)index{
    PlaySongViewController *play = [[PlaySongViewController alloc]initWithNibName:@"PlaySongViewController" bundle:nil];
    play.songArr = songarr;
    play.index = index;
    play.pauseOnLoad = ![Util isMusicPlaying];
    [self.navigationController pushViewController:play animated:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{
    gMP3Player.view.frame = CGRectMake(0, gMP3Player.view.frame.origin.y + 50, self.view.frame.size.width, 50);
    [self.view addSubview: gMP3Player.view];
    gMP3Player.delegate = self;
    
    if (gMP3Player.song.songId.length>0) {
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, gMP3Player.view.frame.origin.y-self.tableView.frame.origin.y);
    }
    else{
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height-self.tableView.frame.origin.y);
    }
    
    if (self.categories) {
        [self.lblTitle setText:self.categories.name];
        [self.revealBtn setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
        [self.revealBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        [self setRevealBtn];
        
    }
    
}



-(void)getData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ModelManager getListCategoryWithPage:currentPage WithSuccess:^(NSMutableArray *arr) {
            self.categoryArr = arr;
            [self.tableView reloadData];
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        } failure:^(NSString *err) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    });
    
}
-(void)getSubCate{
        [ModelManager getSubCategoryWithCategory:self.categories andPage:1 andSuccess:^(NSMutableArray *arr) {
            
            [self.categoryArr removeAllObjects];
            self.categoryArr = arr;
            [self.tableView reloadData];
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
        } failure:^(NSString *err) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
        }];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.categoryArr.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        
        Categories *a = [self.categoryArr objectAtIndex:indexPath.row];
        
        cell.textLabel.text = a.name;
        
    }
    
    
    if (indexPath.row%2==0) {
        [cell setBackgroundColor:[UIColor colorWithRed:219/255.0 green:214/255.0 blue:209/255.0 alpha:1.0]];
    }
    else{
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    
    return cell;

}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Categories *cate = [self.categoryArr objectAtIndex:indexPath.row];
    
    if (cate.haveSub) {
        
        CategoryTableViewController *cateVC = [[CategoryTableViewController alloc]initWithNibName:@"CategoryTableViewController" bundle:nil];
        cateVC.categories = cate;
        [self.navigationController pushViewController:cateVC animated:YES];
        
    }else{
        TopSongViewController *top = [[TopSongViewController alloc]initWithNibName:@"TopSongViewController" bundle:nil];
        top.category = [self.categoryArr objectAtIndex:indexPath.row];
        top.fromWhichView = VIEW_CATEGORIES;
        _isTopSong = YES;
        [self.navigationController pushViewController:top animated:YES];
    }

}

#pragma mark - Drag delegate methods

- (void)dragTableDidTriggerRefresh:(UITableView *)tableView
{

    
    //send refresh request(generally network request) here
    [self.categoryArr removeAllObjects];
    //        <bug4> modify
    currentPage = 1;
    
    [self getData];

    
}

- (void)dragTableRefreshCanceled:(UITableView *)tableView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishRefresh) object:nil];
}

- (void)dragTableDidTriggerLoadMore:(UITableView *)tableView{
    currentPage = 1;
    [self getData];
}


- (void)dragTableLoadMoreCanceled:(UITableView *)tableView{
    
}


@end
