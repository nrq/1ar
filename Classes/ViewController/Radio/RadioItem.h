//
//  RadioItem.h
//  PTMusicApp
//
//  Created by tuan vn on 5/9/16.
//  Copyright © 2016 Fruity Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RadioItem : NSObject

@property (nonatomic, strong) NSString *radioId;
@property (nonatomic, strong) NSString *radioName;
@property (nonatomic, strong) NSString *radioLink;
@property (nonatomic, strong) NSString *radioMirlx;

@property (nonatomic, strong) NSString *radioType;
@property (nonatomic, strong) NSString *radioStatus;


@end
