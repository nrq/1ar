//
//  ModelManager.h
//  PTMusicApp
//
//  Created by hieu nguyen on 12/20/14.
//  Copyright (c) 2014 Fruity Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Song.h"
#import "Categories.h"
#import "ResponseObject.h"
#import "RadioItem.h"

typedef void (^APIClientCompletionBlock)(ResponseObject* responseObject);

@interface ModelManager : NSObject
+(void)getListSongWithSuccess:(void (^)(NSMutableArray *))success
                      failure:(void (^)(NSString *))failure;

+(void)getListTopSongWithpage:(NSString *)page Success:(void (^)(NSMutableArray *))success
                      failure:(void (^)(NSString *))failure;

+(void)getListAllSongWithPage:(NSString *)page Success:(void (^)(NSMutableArray *))success
                      failure:(void (^)(NSString *))failure;

+(void)getListAlbumWithPage:(int) page andSuccess:(void (^)(NSMutableArray *))success
                failure:(void (^)(NSString *))failure;
+(void)getListCategoryWithSuccess:(void (^)(NSMutableArray *))success
                          failure:(void (^)(NSString *))failure;

+(void)getSubCategoryWithCategory:(Categories *)category andPage:(NSInteger)thePage
                       andSuccess:(void (^)(NSMutableArray *))success
                          failure:(void (^)(NSString *))failure;

+(void)getListSongByCategoryId:(NSString *)categoryId
                          page:(int )page
                   WithSuccess:(void (^)(NSMutableArray *))success
                       failure:(void (^)(NSString *))failure;

+(void)getListSongByAlbumId:(NSString *)albumId
                       page:(int)page
                WithSuccess:(void (^)(NSMutableArray *))success
                    failure:(void (^)(NSString *))failure;

+(void)searchSongBykey:(NSString *)key
                  page:(int)page
           WithSuccess:(void (^)(NSMutableArray *))success
               failure:(void (^)(NSString *))failure;

+(void)updateSong:(NSString *)songId
             path:(NSString *)path
      WithSuccess:(void (^)(NSDictionary *))success
          failure:(void (^)(NSString *))failure;
+(void)getListSongWithType:(NSString *)type withPage:(NSString *)page
               WithSuccess:(void (^)(NSMutableArray *))success
                   failure:(void (^)(NSString *))failure;


+(void)registerDevice:(NSString*)deviceID WithBlock:(APIClientCompletionBlock)block;



+(void)getListCategoryWithPage:(NSInteger)thePage WithSuccess:(void (^)(NSMutableArray *))success
                       failure:(void (^)(NSString *))failure;
+(void)getBannerWithType:(NSString*)type WithSuccess:(void (^)(NSMutableArray *))success
                 failure:(void (^)(NSString *))failure;
+(void)getListRadioWithSuccess:(void (^)(RadioItem *))success
                       failure:(void (^)(NSString *))failure;
+(Song *)parseSongFromDic:(NSDictionary *)dic;
@end
