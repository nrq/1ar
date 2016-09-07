//
//  RevealViewController.m
//  JStyle2
//
//  Created by hieu nguyen on 11/3/14.
//  Copyright (c) 2014 Fruity. All rights reserved.
//

#import "RevealViewController.h"
#import "RevealCell.h"
#import "SWRevealViewController.h"

#import "AlbumViewController.h"
#import "AboutViewController.h"
#import "CategoryViewController.h"

#import "PlaylistViewController.h"
#import "SearchViewController.h"
#import "TopSongViewController.h"
#import "DatabaseManager.h"
#import "Macros.h"
#import "SVPullToRefresh.h"
#import "UITableView+DragLoad.h"
#import "MultipleViewController.h"
#import "RadioViewController.h"
#import "ListRadioViewController.h"

@interface RevealViewController ()

@end

@implementation RevealViewController{
    NSIndexPath *selectedIndexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.tblView setBackgroundColor:[UIColor colorWithRed:0.188 green:0.239 blue:0.302 alpha:1]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    [self.tblView selectRowAtIndexPath:indexPath
                           animated:NO
                     scrollPosition:UITableViewScrollPositionMiddle];
    self.tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.navigationController setNavigationBarHidden:YES];
    if (IS_IPAD()) {
        CGRect rect = self.tblView.frame;
        rect.size.width = self.view.bounds.size.width;
        rect.size.height = self.view.bounds.size.height - rect.origin.y;
        self.tblView.frame = rect;
    }
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

#pragma mark UITABALEVIEW DATASOURCE


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = SECTION_MUSIC;
            break;
        case 1:
            sectionName = SECTION_TOOL;
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 0;
    }
    return 40;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    float width = SCREEN_WIDTH_PORTRAIT;
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,0,width,244)];
    tempView.backgroundColor=[UIColor colorWithRed:0.188 green:0.239 blue:0.302 alpha:1];
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(10,10,width,24)];
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.shadowColor = [UIColor clearColor];
    tempLabel.shadowOffset = CGSizeMake(0,60);
    tempLabel.textColor = [UIColor whiteColor]; //here you can change the text color of header.
    UIView *line ;
    
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = SECTION_MUSIC;
            break;
        case 1:
            sectionName = SECTION_TOOL;
            
            break;
        default:
            sectionName = @"";
            break;
    }
    
    tempLabel.text = sectionName;
    
    [tempView addSubview:tempLabel];
    line = [[UIView alloc]initWithFrame:CGRectMake(0,40,width,1)];
    line.backgroundColor= RGB(91, 92, 102);
    [tempView addSubview:line];
    
    return tempView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 44;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    RevealCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RevealCell"];
    
    if (!cell) {
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,44,SCREEN_WIDTH_PORTRAIT,0.5)];
        line.backgroundColor= RGB(91, 92, 102);
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RevealCell" owner:nil options:nil] objectAtIndex:0];
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 0:
                    cell.imgView.image = [UIImage imageNamed:@"ic_top_chart.png"];
                    cell.nameLbl.text = MENU_TOP_SONG;
                    break;
                case 1:
                    cell.imgView.image = [UIImage imageNamed:@"menu_latest.png"];
                    cell.nameLbl.text = MENU_ALL_SONG;
                    break;
                case 2:
                    cell.imgView.image = [UIImage imageNamed:@"menu_seriers.png"];
                    cell.nameLbl.text = MENU_ALBUM;
                    break;
                case 3:
                    cell.imgView.image = [UIImage imageNamed:@"menu_categories.png"];
                    cell.nameLbl.text = MENU_CATEGORY;
                    break;
                case 4:
                    cell.imgView.image = [UIImage imageNamed:@"menu_playlist.png"];
                    cell.nameLbl.text = MENU_PLAYLIST;
                    [cell addSubview:line];
                    break;
                default:
                    break;
            }
        }
        
        if (indexPath.section == 1) {
            switch (indexPath.row) {
                case 0:
                    cell.imgView.image = [UIImage imageNamed:@"menu-search-icon.png"];
                    cell.nameLbl.text = MENU_SEARCH;
                    
                    break;
                case 1:
                    cell.imgView.image = [UIImage imageNamed:@"menu_radio.png"];
                    cell.nameLbl.text = MENU_RADIO;
                    break;
                case 2:
                    cell.imgView.image = [UIImage imageNamed:@"menu_reward.png"];
                    cell.nameLbl.text = MENU_GOOD_APP;
                    break;
                case 3:
                    cell.imgView.image = [UIImage imageNamed:@"icon_download.png"];
                    cell.nameLbl.text = MENU_MY_DOWNLOAD;
                    break;
                case 4:
                    cell.imgView.image = [UIImage imageNamed:@"ic_about.png"];
                    cell.nameLbl.text = MENU_ABOUT;
                    break;
                default:
                    break;
            }
        }

        UIImageView *img = [[UIImageView alloc]initWithFrame:cell.frame];
        img.image = [UIImage imageNamed:@"bg_item_menu_select.png"];
        [cell setSelectedBackgroundView:img];

        [cell setBackgroundColor:[UIColor clearColor]];

        
        cell.imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
   // if (indexPath.row == cell.) {
        cell.ViewSelect.hidden = YES;
   // }
    
    
   
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

//    if (indexPath.section == 1 && indexPath.row == 1) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:GOODAPP_URL]];
//        return;
//    }
    UIViewController *frontViewController;
    
    SWRevealViewController *revealController = self.revealViewController;
    if (indexPath.section==0) {
        switch (indexPath.row) {
                
            case 0:
                frontViewController = [[TopSongViewController alloc]initWithNibName:@"TopSongViewController" bundle:nil];
                ((TopSongViewController *) frontViewController).fromWhichView = VIEW_TOP_SONGS;
                _isTopSong = YES;
                break;
            case 1:
                frontViewController = [[TopSongViewController alloc]initWithNibName:@"TopSongViewController" bundle:nil];
                ((TopSongViewController *) frontViewController).fromWhichView = VIEW_ALBUMS;
                _isTopSong = NO;
                break;
            case 2:
                frontViewController = [[AlbumViewController alloc]initWithNibName:@"AlbumViewController" bundle:nil];
                break;
            case 3:
                frontViewController = [[CategoryViewController alloc]initWithNibName:@"CategoryViewController" bundle:nil];
                break;
            case 4:
                frontViewController = [[PlaylistViewController alloc]initWithNibName:@"PlaylistViewController" bundle:nil];
                break;

            default:
                break;
        }

    }
    else{
        switch (indexPath.row) {
                
            case 0:
                frontViewController = [[SearchViewController alloc]initWithNibName:@"SearchViewController" bundle:nil];
                break;
            case 1:
//                frontViewController = [[ListRadioViewController alloc]initWithNibName:@"ListRadioViewController" bundle:nil];

                frontViewController = [[RadioViewController alloc]initWithNibName:@"RadioViewController" bundle:nil];
                [_audioPlayer pause];
                [gMP3Player onPlayPause:nil];

                break;
            case 2:
                frontViewController = [[MultipleViewController alloc]initWithNibName:@"MultipleViewController" bundle:nil];
                
                break;

            case 3:
                
                frontViewController = [[TopSongViewController alloc]initWithNibName:@"TopSongViewController" bundle:nil];
                ((TopSongViewController *) frontViewController).fromWhichView = VIEW_MY_DOWNLOAD;
    
                break;
            case 4:
                
                frontViewController = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
                break;
                
            default:
                break;
        }

    }
    [revealController pushFrontViewController:frontViewController animated:YES];

    if (selectedIndexPath != nil) {
        RevealCell *cell = [tableView cellForRowAtIndexPath:selectedIndexPath];
        cell.ViewSelect.hidden = YES;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    RevealCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.ViewSelect.hidden = NO;
    cell.backgroundColor = [UIColor colorWithRed:41/255.0f green:55/255.0f blue:66/255.0f alpha:1.0];

    selectedIndexPath = indexPath;
    

}
-(void)loginSuccess{
    [self.tblView reloadData];
    SWRevealViewController *revealController = self.revealViewController;
   
    [revealController setFrontViewPosition:FrontViewPositionRight];
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
@end
