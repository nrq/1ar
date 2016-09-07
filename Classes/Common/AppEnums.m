//
//  AppEnums.m
//  PTMusicApp
//
//  Created by Zaid Pathan on 07/08/16.
//  Copyright © 2016 Fruity Solution. All rights reserved.
//

#import "AppEnums.h"

@implementation AppEnums

+ (NSString*)nameOfScreenType:(ScreenType)screenType{
    if (screenType == Favorite) {
        return @"favorite";
    }else if (screenType == Latest) {
        return @"latest";
    }else if (screenType == Series) {
        return @"series";
    }else if (screenType == CategoriesScreen) {
        return @"categories";
    }else{
        return @"";
    }
}

+ (NSString*)nameOfSubScreenType:(SubScreenType)subScreenType{
    if (subScreenType == None) {
        return @"";
    }else if (subScreenType == SubCategory) {
        return @"subcategory";
    }else if (subScreenType == SubSeries) {
        return @"subseries";
    }else if (subScreenType == SubCategoryDetails) {
        return @"subcategorydetails";
    }else{
        return @"";
    }
}

+ (NSString*)nameOfId:(SubScreenType)subScreenType{
    if (subScreenType == None) {
        return @"";
    }else if (subScreenType == SubCategory) {
        return @"categoryid";
    }else if (subScreenType == SubSeries) {
        return @"seriesid";
    }else if (subScreenType == SubCategoryDetails) {
        return @"subcategoryid";
    }else{
        return @"";
    }
}

@end