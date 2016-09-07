//
//  AboutWebViewController.h
//  PTMusicApp
//
//  Created by tuan vn on 5/17/16.
//  Copyright © 2016 Fruity Solution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutWebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (strong, nonatomic) NSString *textURL;

@end
