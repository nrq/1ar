//
//  RadioViewController.m
//  PTMusicApp
//
//  Created by tuan vn on 4/28/16.
//  Copyright © 2016 Fruity Solution. All rights reserved.
//

#import "RadioViewController.h"
#import "MBProgressHUD.h"
#import "ModelManager.h"
#import "Validator.h"
#import "RadioItem.h"
#import "MBProgressHUD.h"
#import "BannerItem.h"
#import "AsyncImageView.h"
#import "Global.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"

@interface RadioViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *bannerImage;
@property (strong, nonatomic) MPMoviePlayerController *mvpc;
@property (weak, nonatomic) IBOutlet UIButton *btnTouchBanner;
@property (strong, nonatomic) NSString *currentBannerURL;

@end

@implementation RadioViewController{

}
-(void)viewWillAppear:(BOOL)animated{
    [gMP3Player.pauseBtn setBackgroundImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
    [_audioPlayer pause];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealController = self.revealViewController;
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    [_revealBtn addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    

   /* if ([self.radioItem.radioType isEqualToString:@"1"]) {
        NSString *s = @"<iframe src=\"https://mixlr.com/users/3778788/embed?color=26328f&autoplay=true\" width=\"100%\" height=\"180px\" scrolling=\"no\" frameborder=\"no\" marginheight=\"0\" marginwidth=\"0\"></iframe><small><a href=\"http://mixlr.com/nqlive--2\" style=\"color:#1a1a1a;text-align:left; font-family:Helvetica, sans-serif; font-size:11px;\">NQLive is on Mixlr</a></small>";
        [self.webView loadHTMLString:s baseURL:nil];

    }else{
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.radioItem.radioLink]]];
    
    }*/

//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.radioItem.radioLink]]];

    if (![DELEGATE isConnected]) {
        [Util showMessage:ALERT_TURN_ON_DATA withTitle:ALERT_MOBILE_DATA_OFF];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [ModelManager getListRadioWithSuccess:^(RadioItem *item) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                self.mvpc = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:item.radioLink]];
                self.mvpc.shouldAutoplay = YES;
                
                self.mvpc.controlStyle = MPMovieControlStyleEmbedded;
                [self.mvpc setMovieSourceType:MPMovieSourceTypeStreaming];
                [self.mvpc prepareToPlay];
                [self.mvpc.view setFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
                [self.view addSubview:self.mvpc.view];
                self.mvpc.view.backgroundColor = [UIColor whiteColor];
                [self.mvpc play];
                
                
                
            } failure:^(NSString *err) {
                
            }];
            
            
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [ModelManager getBannerWithType:@"1" WithSuccess:^(NSArray *arr) {
                
                self.btnTouchBanner.hidden = false;
                
                BannerItem *b = arr[0];
                self.bannerImage.imageURL = [NSURL URLWithString:b.bannerImage];
                self.currentBannerURL = b.bannerURL;
                NSLog(@"%@", b.bannerImage);
                
            } failure:^(NSString *err) {
                
            }];
        });

    }
  
}

- (IBAction)touchBanner:(id)sender {
    NSURL *url = [NSURL URLWithString:self.currentBannerURL];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}


- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    if (![DELEGATE isConnected]) {
        [Util showMessage:ALERT_TURN_ON_DATA withTitle:ALERT_MOBILE_DATA_OFF];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}

@end
