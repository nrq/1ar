//
//  CategoryTableViewController.h
//  PTMusicApp
//
//  Created by tuan vn on 5/3/16.
//  Copyright © 2016 Fruity Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Categories.h"


@interface CategoryTableViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *revealBtn;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (strong, nonatomic) Categories *categories;
@property (strong, nonatomic) NSMutableArray *categoryArr;

@end
