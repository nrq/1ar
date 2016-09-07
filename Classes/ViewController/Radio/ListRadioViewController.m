//
//  ListRadioViewController.m
//  PTMusicApp
//
//  Created by tuan vn on 5/9/16.
//  Copyright © 2016 Fruity Solution. All rights reserved.
//

#import "ListRadioViewController.h"
#import "ModelManager.h"
#import "Validator.h"
#import "RadioItem.h"
#import "MBProgressHUD.h"
#import "RadioViewController.h"
#import "AppDelegate.h"

@interface ListRadioViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ListRadioViewController{
    NSArray *arrayRadio;

}

- (void)viewDidLoad {
    [super viewDidLoad];

    SWRevealViewController *revealController = self.revealViewController;
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    [_revealBtn addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (![DELEGATE isConnected]) {
        [Util showMessage:ALERT_TURN_ON_DATA withTitle:ALERT_MOBILE_DATA_OFF];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrayRadio.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        
        RadioItem *s = [arrayRadio objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ ",s.radioName];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
    }
    
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RadioItem *s = [arrayRadio objectAtIndex:indexPath.row];
    
    RadioViewController *controller = [[RadioViewController alloc]initWithNibName:@"RadioViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}



@end
