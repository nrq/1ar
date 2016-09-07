//
//  WebViewController.h
//  PTMusicApp
//
//  Created by tuan vn on 4/28/16.
//  Copyright © 2016 Fruity Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BannerItem.h"

@interface WebViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) BannerItem *item;

@property (weak, nonatomic) IBOutlet UILabel *titleText;

@end
