//
//  CategoryViewController.m
//  PTMusicApp
//
//  Created by hieu nguyen on 12/6/14.
//  Copyright (c) 2014 Fruity Solution. All rights reserved.
//

#import "CategoryViewController.h"
#import "SWRevealViewController.h"
#import "AlbumCell.h"
#import "Categories.h"
#import "AsyncImageView.h"
#import "ModelManager.h"
#import "MBProgressHUD.h"
#import "TopSongViewController.h"
#import "PlaySongViewController.h"
#import "CategoryTableViewController.h"
#import "UITableView+DragLoad.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"

@interface CategoryViewController ()<MP3PlayerDelegate>

@property BOOL isLoadingMoreData;
@property int currentPage;

@end

@implementation CategoryViewController{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPage = 1;
    self.categoryArr = [[NSMutableArray alloc]init];
    
//    if (![DELEGATE isConnected]) {
//        [Util showMessage:ALERT_TURN_ON_DATA withTitle:ALERT_MOBILE_DATA_OFF];
//    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [self setupCollectionView];
        if (self.categories) {
            [self getSubCate];
            [self.lblTitle setText:self.categories.name];
            [self.revealBtn setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
            [self.revealBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
            
        }else{
            [self getData];
            [self setRevealBtn];
            
        }
//    }
    
   /* if (self.categories.categoryId.length==0) {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getData) userInfo:nil repeats:NO];
        [self setRevealBtn];
    }
    else{
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getSubCate) userInfo:nil repeats:NO];
        [self.lblTitle setText:self.categories.name];
        [self.revealBtn setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
        [self.revealBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    }
    */
    // Do any additional setup after loading the view from its nib.
}

-(void)NextDetailWithSongArr:(NSMutableArray *)songarr andInde:(int)index{
    PlaySongViewController *play = [[PlaySongViewController alloc]initWithNibName:@"PlaySongViewController" bundle:nil];
    play.songArr = songarr;
    play.index = index;
    play.pauseOnLoad = ![Util isMusicPlaying];
    [self.navigationController pushViewController:play animated:YES];
    
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    gMP3Player.view.frame = CGRectMake(0, gMP3Player.view.frame.origin.y + 50, self.view.frame.size.width, 50);
    [self.view addSubview: gMP3Player.view];
    gMP3Player.delegate = self;
    
    if (gMP3Player.song.songId.length>0) {
        self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x, self.collectionView.frame.origin.y, self.collectionView.frame.size.width, gMP3Player.view.frame.origin.y-self.collectionView.frame.origin.y);
    }
    else{
        self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x, self.collectionView.frame.origin.y, self.collectionView.frame.size.width, self.view.frame.size.height-self.collectionView.frame.origin.y);
    }
    
    if (self.categories) {
        [self.lblTitle setText:self.categories.name];
        [self.revealBtn setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
        [self.revealBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        [self setRevealBtn];
        
    }
    
}
-(void)setRevealBtn{
    SWRevealViewController *revealController = self.revealViewController;
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    [_revealBtn addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)getData{

    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ModelManager getListCategoryWithSuccess:^(NSMutableArray *arr) {
            self.categoryArr = arr;
            [self.collectionView reloadData];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        } failure:^(NSString *err) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    });*/
    
        [ModelManager getListCategoryWithPage:self.currentPage WithSuccess:^(NSMutableArray *arr) {
            [self.categoryArr addObjectsFromArray:arr];
            [self.collectionView reloadData];

            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        } failure:^(NSString *err) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    
}
-(void)getSubCate{

        [ModelManager getSubCategoryWithCategory:self.categories andPage:_currentPage andSuccess:^(NSMutableArray *arr) {
         

            [self.categoryArr addObjectsFromArray:arr];
            [self.collectionView reloadData];
            
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        } failure:^(NSString *err) {
             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];

}
-(void)setupCollectionView {
    [self.collectionView registerClass:[AlbumCell class] forCellWithReuseIdentifier:@"AlbumCell"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:1.0f];
    [flowLayout setMinimumLineSpacing:10.0f];
    [flowLayout setItemSize:CGSizeMake(135, 180)];
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.contentSize = [self collectionViewContentSize];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(onCollectionViewRefresh:)
             forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
}


- (CGSize)collectionViewContentSize
{
    return CGSizeMake(50, self.collectionView.frame.size.height);
}



#pragma mark - UICollectionView Datasource
// 1

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.categoryArr.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    
    return 1;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(135, 180);
}

// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCell *cell = (AlbumCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
    
    Categories *a = [self.categoryArr objectAtIndex:indexPath.row];
    [cell.avatarImg setImageWithURL:[NSURL URLWithString:a.image] placeholderImage:nil options:SDWebImageRetryFailed];
    cell.nameLbl.text = a.name;
    cell.nameLbl.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
   /* Categories *cate = [self.categoryArr objectAtIndex:indexPath.row];
    if ([cate.isParent isEqualToString:@"1"]) {
        CategoryViewController *cateVC = [[CategoryViewController alloc]initWithNibName:@"CategoryViewController" bundle:nil];
        cateVC.categories = cate;
        [self.navigationController pushViewController:cateVC animated:YES];
        
    }
    else{
        TopSongViewController *top = [[TopSongViewController alloc]initWithNibName:@"TopSongViewController" bundle:nil];
        top.category = [self.categoryArr objectAtIndex:indexPath.row];
        top.fromWhichView = VIEW_CATEGORIES;
        [self.navigationController pushViewController:top animated:YES];
    }*/
    
    Categories *cate = [Categories new];
    cate = [self.categoryArr objectAtIndex:indexPath.row];
    
    if (cate.haveSub) {
        if (cate.level > 2){
            
            CategoryTableViewController *cateVC = [[CategoryTableViewController alloc]initWithNibName:@"CategoryTableViewController" bundle:nil];
            cateVC.categories = cate;
            [self.navigationController pushViewController:cateVC animated:YES];

        }else{
            
            CategoryViewController *cateVC = [[CategoryViewController alloc]initWithNibName:@"CategoryViewController" bundle:nil];
            cateVC.categories = cate;
            [self.navigationController pushViewController:cateVC animated:YES];

        }
      
    }else{
        TopSongViewController *top = [[TopSongViewController alloc]initWithNibName:@"TopSongViewController" bundle:nil];
        top.category = [self.categoryArr objectAtIndex:indexPath.row];
        top.fromWhichView = VIEW_CATEGORIES;
        _isTopSong = YES;
        [self.navigationController pushViewController:top animated:YES];
    }
    
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}



// 3
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(18, 18, 18, 18);
}

- (void)onCollectionViewRefresh:(id)sender
{
    [(UIRefreshControl *)sender endRefreshing];
    
//    if (![DELEGATE isConnected]) {
//        [Util showMessage:ALERT_TURN_ON_DATA withTitle:ALERT_MOBILE_DATA_OFF];
//    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getData) userInfo:nil repeats:NO];
//    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height + 80)
    {
        if (self.isLoadingMoreData == NO)
        {
            self.isLoadingMoreData = YES;
            
//            if (![DELEGATE isConnected]) {
//                [Util showMessage:ALERT_TURN_ON_DATA withTitle:ALERT_MOBILE_DATA_OFF];
//            } else {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(loadMore) userInfo:nil repeats:NO];
//            }
        }
    }
}

-(void) loadMore{
    self.currentPage = self.currentPage + 1;
    if (_categories!= nil) {
        [self getSubCate];
    }

//        [ModelManager getListAlbumWithPage:self.currentPage andSuccess:^(NSMutableArray *arr) {
//            if ([arr count] > 0)
//            {
//                [self.albumArr addObjectsFromArray:arr];
//                [self.collectionView reloadData];
//            }
//            self.isLoadingMoreData = NO;
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        } failure:^(NSString *err) {
//            self.isLoadingMoreData = NO;
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        }];
        
        [ModelManager  getListCategoryWithPage:self.currentPage WithSuccess:^(NSMutableArray *arr) {
            if ([arr count] > 0){
                [self.categoryArr addObjectsFromArray: arr];
                [self.collectionView reloadData];
            }
            
            self.isLoadingMoreData = NO;

            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        } failure:^(NSString *err) {
            self.isLoadingMoreData = NO;

            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
}

@end
