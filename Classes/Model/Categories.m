
//
//  Categories.m
//  PTMusicApp
//
//  Created by hieu nguyen on 12/20/14.
//  Copyright (c) 2014 Fruity Solution. All rights reserved.
//

#import "Categories.h"

@implementation Categories

-(BOOL)haveSub{
    if (self.countSub > 0) {
        return YES;
    }else{
        return NO;
    }
}

@end
