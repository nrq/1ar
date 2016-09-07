//
//  AboutViewController.m
//  PTMusicApp
//
//  Created by hieu nguyen on 12/6/14.
//  Copyright (c) 2014 Fruity Solution. All rights reserved.
//

#import "AboutViewController.h"
#import "SWRevealViewController.h"
#import "PlaySongViewController.h"
#import "AboutWebViewController.h"

@interface AboutViewController ()<MP3PlayerDelegate>
//@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation AboutViewController{
    NSString *aboutText;
    NSString *aboutText2;
    NSString *aboutText3;
    NSString *aboutText4;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setRevealBtn];
    gMP3Player.view.frame = CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50);
    [self.view addSubview: gMP3Player.view];
   
    if (gMP3Player.song.songId.length>0) {
        self.heightToBottom.constant = 58;
    }else{
        self.heightToBottom.constant = 8;
    }
    
    gMP3Player.delegate = self;

    
    
}
-(void)viewDidLayoutSubviews{
    for (UIView* subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    UILabel *textViewText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, 1000)];
    
    //    aboutText = @"NurulQuran Institute is a non-profit, non-sectarian & non-political  organization working since years dedicated to spreading authentic Islamic knowledge of\nAl Quran & Sunnah\nthrough education & social welfare while making it easily attainable for all walks of life.\nOur Vision is to Enlighten the hearts, homes and lives with the Nur of Al Quran.\n\nFor More Details Visit Us :\nNurulQuran.com\nnq-international.com";
    
    aboutText = @"NurulQuran Institute is a non-profit, non-sectarian & non-political  organization working since years dedicated to spreading authentic Islamic knowledge of\nAl Quran & Sunnah\nthrough education & social welfare while making it easily attainable for all walks of life.\nOur Vision is to Enlighten the hearts, homes and lives with the Nur of Al Quran.";
    
    aboutText2 = @"For More Details Visit Us :";
    aboutText3 = @"NurulQuran.com";
    aboutText4 = @"nq-international.com";
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:aboutText ];
    [att addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0,  aboutText.length)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [att addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aboutText length])];
    
    //    [att addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(aboutText.length - 35,  35)];
    [att addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(aboutText.length - 80,  80)];
    [att addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(aboutText.length - 190,  17)];
    [att addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(0,  20)];
    
    textViewText.attributedText = att;
    textViewText.numberOfLines = 0;
    [textViewText sizeToFit];
    
    [self.scrollView addSubview:textViewText];
    
    UILabel *textViewText2 = [[UILabel alloc] initWithFrame:CGRectMake(0, textViewText.frame.size.height + 10, self.scrollView.frame.size.width, 30)];
    textViewText2.text = aboutText2;
    textViewText2.textAlignment = NSTextAlignmentCenter;
    textViewText2.numberOfLines = 0;
    [self.scrollView addSubview:textViewText2];
    
    UILabel *textViewText3 = [[UILabel alloc] initWithFrame:CGRectMake(0, textViewText.frame.size.height +  textViewText2.frame.size.height + 10, self.scrollView.frame.size.width, 30)];
    textViewText3.text = aboutText3;
    textViewText3.textAlignment = NSTextAlignmentCenter;
    textViewText3.numberOfLines = 0;
    textViewText3.font = [UIFont boldSystemFontOfSize:20];
    [self.scrollView addSubview:textViewText3];
    
    
    UILabel *textViewText4 = [[UILabel alloc] initWithFrame:CGRectMake(0, textViewText.frame.size.height +  textViewText2.frame.size.height + 10 +  textViewText3.frame.size.height, self.scrollView.frame.size.width, 30)];
    textViewText4.text = aboutText4;
    textViewText4.textAlignment = NSTextAlignmentCenter;
    textViewText4.numberOfLines = 0;
    textViewText4.font = [UIFont boldSystemFontOfSize:20];
    [self.scrollView addSubview:textViewText4];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = textViewText3.frame;
    [btn1 addTarget:self action:@selector(goToLink1) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = textViewText4.frame;
    [btn2 addTarget:self action:@selector(goToLink2) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btn2];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, textViewText2.frame.size.height + 30  + textViewText.frame.size.height + textViewText3.frame.size.height + textViewText4.frame.size.height);
    
}

-(void)goToLink1{
    AboutWebViewController *controller = [[AboutWebViewController alloc]initWithNibName:@"AboutWebViewController" bundle:nil];
    controller.textURL = @"http://nurulquran.com/";
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)goToLink2{
    AboutWebViewController *controller = [[AboutWebViewController alloc]initWithNibName:@"AboutWebViewController" bundle:nil];
    controller.textURL = @"http://nq-international.com";
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)NextDetailWithSongArr:(NSMutableArray *)songarr andInde:(int)index{
    PlaySongViewController *play = [[PlaySongViewController alloc]initWithNibName:@"PlaySongViewController" bundle:nil];
    play.songArr = songarr;
    play.index = index;
    play.pauseOnLoad = ![Util isMusicPlaying];
    [self.navigationController pushViewController:play animated:YES];
    
}


-(void)setRevealBtn{
    SWRevealViewController *revealController = self.revealViewController;
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    [_revealBtn addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
}

@end
