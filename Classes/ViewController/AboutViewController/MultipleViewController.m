//
//  MultipleViewController.m
//  PTMusicApp
//
//  Created by tuan vn on 4/26/16.
//  Copyright © 2016 Fruity Solution. All rights reserved.
//

#import "MultipleViewController.h"
#import "SWRevealViewController.h"
#import "PlaySongViewController.h"
#import "AboutWebViewController.h"

@interface MultipleViewController ()<MP3PlayerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation MultipleViewController{
    NSString *aboutText;
    NSString *aboutText2;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setRevealBtn];
    
    
   

}
-(void)viewDidLayoutSubviews{
    for (UIView* subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    UILabel *textViewText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, 1000)];
    
    aboutText = @"Race to invest for your Akhirah\n\nMessenger of Allah (Sallallahu 'alaihi wa sallam) said: \"When a man passes away, his good deeds will also come to an end except for three: Sadaqah Jariyah (ceaseless charity); a knowledge which is beneficial, or a virtuous descendant who prays for him (for the deceased)\" { Sahih Muslim }\n\nAny Contribution Small (OR) Large\nIn Shaa Allah will go a long way towards spreading the word of Allah Subhanawatala to masses and in Sawaab - E - Jaariya activities promoting religious literacy.";
    
    aboutText2 = @"http://nqdonation.com/";
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:aboutText ];
    [att addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0,  aboutText.length)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [att addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aboutText length])];
    
    //    [att addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:77/255.0 green:56/255.0 blue:65/255.0 alpha:1.0] range:NSMakeRange(aboutText.length - 22,  22)];
    //    [att addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(aboutText.length - 22,  22)];
    
    [att addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(0,  31)];
    
    [att addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:17] range:NSMakeRange(88,  216)];
    [att addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:NSMakeRange(88,  216)];
    
    textViewText.attributedText = att;
    textViewText.numberOfLines = 0;
    [textViewText sizeToFit];
    [self.scrollView addSubview:textViewText];
    
    UILabel *textViewText2 = [[UILabel alloc] initWithFrame:CGRectMake(0, textViewText.frame.size.height + 10, self.scrollView.frame.size.width, 30)];
    textViewText2.text = aboutText2;
    textViewText2.textAlignment = NSTextAlignmentCenter;
    textViewText2.numberOfLines = 0;
    textViewText2.textColor = [UIColor colorWithRed:77/255.0 green:56/255.0 blue:65/255.0 alpha:1.0];
    textViewText2.font = [UIFont boldSystemFontOfSize:20] ;
    [self.scrollView addSubview:textViewText2];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = textViewText2.frame;
    [btn1 addTarget:self action:@selector(goToLink1) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btn1];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, textViewText.frame.size.height + 20 + textViewText2.frame.size.height);
    gMP3Player.view.frame = CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50);
    [self.view addSubview: gMP3Player.view];
    if (gMP3Player.song.songId.length>0) {
        //        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height-150);
        [self.scrollView  setContentInset:UIEdgeInsetsMake(0, 0,50, 0)];
        self.heightToBottom.constant = 58;
    }else{
        self.heightToBottom.constant = 8;
    }
    gMP3Player.delegate = self;
}
-(void)goToLink1{
    AboutWebViewController *controller = [[AboutWebViewController alloc]initWithNibName:@"AboutWebViewController" bundle:nil];
    controller.textURL = @"http://nqdonation.com/";
    [self presentViewController:controller animated:YES completion:nil];
}


-(void)NextDetailWithSongArr:(NSMutableArray *)songarr andInde:(int)index{
    PlaySongViewController *play = [[PlaySongViewController alloc]initWithNibName:@"PlaySongViewController" bundle:nil];
    play.songArr = songarr;
    play.songIndex = index;
    play.pauseOnLoad = ![Util isMusicPlaying];
    [self.navigationController pushViewController:play animated:YES];
    
}


-(void)setRevealBtn{
    SWRevealViewController *revealController = self.revealViewController;
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    [_revealBtn addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
}



@end
