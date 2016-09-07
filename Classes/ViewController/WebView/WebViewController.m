//
//  WebViewController.m
//  PTMusicApp
//
//  Created by tuan vn on 4/28/16.
//  Copyright © 2016 Fruity Solution. All rights reserved.
//

#import "WebViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface WebViewController ()<UIWebViewDelegate>

@end

@implementation WebViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:self.item.bannerURL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    self.titleText.text =  self.item.bannerTitle;
}

- (IBAction)actionBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
