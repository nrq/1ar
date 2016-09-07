//
//  AppEnums.h
//  PTMusicApp
//
//  Created by Zaid Pathan on 07/08/16.
//  Copyright © 2016 Fruity Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    NoneScreenType          = 0,
    Favorite                = 1,
    Latest                  = 2,
    Series                  = 3,
    CategoriesScreen        = 4
} ScreenType;

typedef enum{
    None        = 0,
    SubCategory = 1,
    SubCategoryDetails = 2,
    SubSeries   = 3
} SubScreenType;


@interface AppEnums : NSObject
+ (NSString*)nameOfScreenType:(ScreenType)screenType;

+ (NSString*)nameOfSubScreenType:(SubScreenType)subScreenType;

+ (NSString*)nameOfId:(SubScreenType)subScreenType;
@end
