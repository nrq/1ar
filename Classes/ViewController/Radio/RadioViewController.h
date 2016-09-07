//
//  RadioViewController.h
//  PTMusicApp
//
//  Created by tuan vn on 4/28/16.
//  Copyright © 2016 Fruity Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioItem.h"
#import <MediaPlayer/MediaPlayer.h>
@interface RadioViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *revealBtn;
@property (strong, nonatomic) RadioItem *item;

@end
