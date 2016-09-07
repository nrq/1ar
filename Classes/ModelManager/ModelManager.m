//
//  ModelManager.m
//  PTMusicApp
//
//  Created by hieu nguyen on 12/20/14.
//  Copyright (c) 2014 Fruity Solution. All rights reserved.
//

#import "ModelManager.h"
#import "Util.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "Validator.h"
#import "Album.h"
#import "Categories.h"
#import "AFURLSessionManager.h"
#import "SVProgressHUD.h"
#import "BannerItem.h"
#import "DatabaseManager.h"
#import "AppEnums.h"

@implementation ModelManager



#pragma mark -------------------------------------------------------------------------------------------------------------------------------------
#pragma mark GET SONG
#pragma mark -------------------------------------------------------------------------------------------------------------------------------------
#define DEVICE_REGISTER @"deviceRegister?gcm_id=%@&ime=%@&type=2&status=1"


+(void)getListSongWithSuccess:(void (^)(NSMutableArray *))success
                      failure:(void (^)(NSString *))failure
{
    NSString*urlStr = [NSString stringWithFormat:@"%@%@",BASE_URL,TOP_SONG];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (![Util isConnectNetwork]) {
        failure(nil);
    }
    else{
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        __weak ASIFormDataRequest *request_ = request;
        [request setTimeOutSeconds:20];
        
        
        [request setCompletionBlock:^{
            
            NSError *e = nil;
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:NSJSONReadingMutableContainers error:&e];
            //            NSString *responseData = [[NSString alloc] initWithData:[request_ responseData] encoding:NSUTF8StringEncoding];
            
            if (!jsonDic) {
                NSLog(@"Error parsing JSON: %@", e);
                if(failure)
                    failure(nil);
            } else {
                if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
                {
                    NSString *allpage = jsonDic[@"allpage"];
                    [Util setObject:allpage forKey:@"allpageTopSong"];
                    NSArray *dicArr = jsonDic[@"data"];
                    NSMutableArray *songArr = [self parseSongFromDicArr:dicArr];
                    success(songArr);
                }
                else if(failure)
                    failure(nil);
            }
        }];
        [request setFailedBlock:^{
            
            NSError *error = [request_ error];
            if (error.code == ASIRequestTimedOutErrorType){
                [Util showMessage:@"No Network" withTitle:nil];
                if(failure)
                    failure(@"No Network");
            }
            else{
                if(failure)
                    failure(nil);
            }
        }];
        [request startAsynchronous];
    }
}


// MARK:- Most Favorite
+(void)getListTopSongWithpage:(NSString *)page Success:(void (^)(NSMutableArray *))success
                      failure:(void (^)(NSString *))failure{
    NSString*urlStr = [NSString stringWithFormat:@"%@%@",BASE_URL,TOP_SONG];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (![Util isConnectNetwork]) {
        NSData *offlineData = [[DatabaseManager defaultDatabaseManager] getOfflineData:Favorite subScreenType:None subId:0 subsubId:0 forPage:[page integerValue]];
        
        [ModelManager handleGetOfflineData:offlineData screenType:Favorite
                             subScreenType:None WithSuccess:^(NSMutableArray *arr) {
                                 success(arr);
                             } failure:^(NSString *failureString) {
                                 failure(nil);
                             }];
    }
    else{
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        __weak ASIFormDataRequest *request_ = request;
        [request setTimeOutSeconds:20];
        //        <topsongbug> add
        [request setPostValue:page forKey:@"page"];
        //        </topsongbug>
        [request setCompletionBlock:^{
            
            NSError *e = nil;
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:NSJSONReadingMutableContainers error:&e];
            //            NSString *responseData = [[NSString alloc] initWithData:[request_ responseData] encoding:NSUTF8StringEncoding];
            NSLog(@"CUONG: responseData: %@", jsonDic);
            if (!jsonDic) {
                NSLog(@"Error parsing JSON: %@", e);
                if(failure)
                    failure(nil);
            } else {
                if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
                {
                    
                    NSArray *dicArr = jsonDic[@"data"];
                    NSMutableArray *songArr = [self parseSongFromDicArr:dicArr];
                    [[DatabaseManager defaultDatabaseManager] storeOffline:Favorite subScreenType:None subId:0 subsubId:0 forPage:[page integerValue] data:[request_ responseData]];
                    success(songArr);
                }
                else if(failure)
                    failure(nil);
            }
        }];
        [request setFailedBlock:^{
            
            NSError *error = [request_ error];
            if (error.code == ASIRequestTimedOutErrorType){
                [Util showMessage:@"No Network" withTitle:nil];
                if(failure)
                    failure(@"No Network");
            }
            else{
                if(failure)
                    failure(nil);
            }
        }];
        [request startAsynchronous];
    }
}


+(void)getListAllSongWithPage:(NSString *)page Success:(void (^)(NSMutableArray *))success
                      failure:(void (^)(NSString *))failure{
    NSString*urlStr = [NSString stringWithFormat:@"%@%@?page=%@",BASE_URL,GET_SONGS,page];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (![Util isConnectNetwork]) {
        failure(nil);
    }
    else{
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        __weak ASIFormDataRequest *request_ = request;
        [request setTimeOutSeconds:20];
        
        [request setPostValue:page forKey:@"page"];
        [request setCompletionBlock:^{
            
            NSError *e = nil;
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:NSJSONReadingMutableContainers error:&e];
            //            NSString *responseData = [[NSString alloc] initWithData:[request_ responseData] encoding:NSUTF8StringEncoding];
            
            if (!jsonDic) {
                NSLog(@"Error parsing JSON: %@", e);
                if(failure)
                    failure(nil);
            } else {
                
                if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
                {
                    NSString *allpage = jsonDic[@"allpage"];
                    [Util setObject:allpage forKey:@"allpageTopSong"];
                    NSArray *dicArr = jsonDic[@"data"];
                    NSMutableArray *songArr = [self parseSongFromDicArr:dicArr];
                    success(songArr);
                }
                else if(failure)
                    failure(nil);
            }
        }];
        [request setFailedBlock:^{
            
            NSError *error = [request_ error];
            if (error.code == ASIRequestTimedOutErrorType){
                [Util showMessage:@"No Network" withTitle:nil];
                if(failure)
                    failure(@"No Network");
            }
            else{
                if(failure)
                    failure(nil);
            }
        }];
        [request startAsynchronous];
    }
}

// MARK:- Latest
+(void)getListSongWithType:(NSString *)type withPage:(NSString *)page
               WithSuccess:(void (^)(NSMutableArray *))success
                   failure:(void (^)(NSString *))failure
{
    NSString*urlStr = [NSString stringWithFormat:@"%@%@?page=%@&type=%@",BASE_URL,GET_SONGS,page,type];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (![Util isConnectNetwork]) {
        NSData *offlineData = [[DatabaseManager defaultDatabaseManager] getOfflineData:Latest subScreenType:None subId:0 subsubId:0 forPage:[page integerValue]];
        
        [ModelManager handleGetOfflineData:offlineData screenType:Latest
                             subScreenType:None WithSuccess:^(NSMutableArray *arr) {
                                 success(arr);
                             } failure:^(NSString *failureString) {
                                 failure(nil);
                             }];
    }
    else{
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        __weak ASIFormDataRequest *request_ = request;
        [request setTimeOutSeconds:20];
        
        
        [request setCompletionBlock:^{
            
            NSError *e = nil;
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:NSJSONReadingMutableContainers error:&e];
            //            NSString *responseData = [[NSString alloc] initWithData:[request_ responseData] encoding:NSUTF8StringEncoding];
            
            if (!jsonDic) {
                NSLog(@"Error parsing JSON: %@", e);
                if(failure)
                    failure(nil);
            } else {
                if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
                {
                    NSString * allpage = jsonDic[@"allpage"];
                    [Util setObject:allpage forKey:@"AllSong"];
                    NSArray *dicArr = jsonDic[@"data"];
                    NSMutableArray *songArr = [self parseSongFromDicArr:dicArr];
                    [[DatabaseManager defaultDatabaseManager] storeOffline:Latest subScreenType:None subId:0 subsubId:0 forPage:[page integerValue] data:[request_ responseData]];
                    success(songArr);
                }
                else if(failure)
                    failure(nil);
            }
        }];
        [request setFailedBlock:^{
            
            NSError *error = [request_ error];
            if (error.code == ASIRequestTimedOutErrorType){
                [Util showMessage:@"No Network" withTitle:nil];
                if(failure)
                    failure(@"No Network");
            }
            else{
                if(failure)
                    failure(nil);
            }
        }];
        [request startAsynchronous];
    }
}
+(void)updateSong:(NSString *)songId
             path:(NSString *)path
      WithSuccess:(void (^)(NSDictionary *))success
          failure:(void (^)(NSString *))failure
{
    NSString*urlStr = [NSString stringWithFormat:@"%@%@?id=%@",BASE_URL,path,songId];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (![Util isConnectNetwork]) {
        failure(nil);
    }
    else{
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        __weak ASIFormDataRequest *request_ = request;
        [request setTimeOutSeconds:20];
        
        
        [request setCompletionBlock:^{
            
            NSError *e = nil;
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:NSJSONReadingMutableContainers error:&e];
            //            NSString *responseData = [[NSString alloc] initWithData:[request_ responseData] encoding:NSUTF8StringEncoding];
            
            if (!jsonDic) {
                NSLog(@"Error parsing JSON: %@", e);
                if(failure)
                    failure(nil);
            } else {
                if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
                {
                    success(jsonDic);
                }
                else if(failure)
                    failure(nil);
            }
        }];
        [request setFailedBlock:^{
            
            NSError *error = [request_ error];
            if (error.code == ASIRequestTimedOutErrorType){
                [Util showMessage:@"No Network" withTitle:nil];
                if(failure)
                    failure(@"No Network");
            }
            else{
                if(failure)
                    failure(nil);
            }
        }];
        [request startAsynchronous];
    }
}
+(Song *)parseSongFromDic:(NSDictionary *)dic{
    Song *s = [[Song alloc]init];
    s.songId = [Validator getSafeString:dic[@"id"]];
    s.name = [Validator getSafeString:dic[@"name"]];
    s.lyrics = [Validator getSafeString:dic[@"lyrics"]];
    s.link = [[Validator getSafeString:dic[@"link"]] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    s.singerName = [Validator getSafeString:dic[@"singerName"]];
    s.albumId = [Validator getSafeString:dic[@"album_id"]];
    s.authorId = [Validator getSafeString:dic[@"author_id"]];
    s.categoryId = [Validator getSafeString:dic[@"category_id"]];
    s.hot = [Validator getSafeString:dic[@"hot"]];
    s.news = [Validator getSafeString:dic[@"new"]];
    s.number = [Validator getSafeString:dic[@"number"]];
    s.localMP3 = [Util objectForKey:[NSString stringWithFormat:@"%@_localFile",s.songId]];
    s.downloadNum = [Validator getSafeString:dic[@"download"]];
    s.viewNum = [Validator getSafeString:dic[@"view"]];
    s.image = [Validator getSafeString:dic[@"image"]];
    s.orderNumber = [Validator getSafeString:dic[@"order_number"]];
    
    NSString *textHtmlNote = [Validator getSafeString:dic[@"description"]];
    NSAttributedString * attrStrNote = [[NSAttributedString alloc] initWithData:[textHtmlNote dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    NSString *finalString = [NSString stringWithString:attrStrNote.string];
    s.desc = finalString;
    
    if (s.viewNum.length == 0) {
        s.viewNum = [Validator getSafeString:dic[@"listen"]];
    }
    return s;
}

+(Song *)parseSongFromDicSearch:(NSDictionary *)dic{
    Song *s = [[Song alloc]init];
    s.songId = [Validator getSafeString:dic[@"id"]];
    s.name = [Validator getSafeString:dic[@"name"]];
    s.lyrics = [Validator getSafeString:dic[@"lyrics"]];
    s.link = [[Validator getSafeString:dic[@"link"]] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    s.singerName = [Validator getSafeString:dic[@"singerName"]];
    s.albumId = [Validator getSafeString:dic[@"album_id"]];
    s.authorId = [Validator getSafeString:dic[@"author_id"]];
    s.categoryId = [Validator getSafeString:dic[@"category_id"]];
    s.hot = [Validator getSafeString:dic[@"hot"]];
    s.news = [Validator getSafeString:dic[@"new"]];
    s.number = [Validator getSafeString:dic[@"number"]];
    s.localMP3 = [Util objectForKey:[NSString stringWithFormat:@"%@_localFile",s.songId]];
    s.downloadNum = [Validator getSafeString:dic[@"download"]];
    s.viewNum = [Validator getSafeString:dic[@"listen"]];
    s.image =[Validator getSafeString:dic[@"image"]];
    s.orderNumber = [Validator getSafeString:dic[@"order_number"]];
    
    NSString *textHtmlNote = [Validator getSafeString:dic[@"description"]];
    NSAttributedString * attrStrNote = [[NSAttributedString alloc] initWithData:[textHtmlNote dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    NSString *finalString = [NSString stringWithString:attrStrNote.string];
    s.desc = finalString;
    
    if (s.viewNum.length == 0) {
        s.viewNum = [Validator getSafeString:dic[@"listen"]];
    }
    return s;
}

+(NSMutableArray *)parseSongFromDicArr:(NSArray *)dicArr{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in dicArr) {
        Song *u = [[Song alloc]init];
        u = [self parseSongFromDic:dic];
        [result addObject:u];
    }
    return result;
}


+(NSMutableArray *)parseSongFromDicArrSearch:(NSArray *)dicArr{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in dicArr) {
        Song *u = [[Song alloc]init];
        u = [self parseSongFromDicSearch:dic];
        [result addObject:u];
    }
    return result;
}



// MARK:- SubCategory details
+(void)getListSongByCategoryId:(NSString *)categoryId
                          page:(int )page
                   WithSuccess:(void (^)(NSMutableArray *))success
                       failure:(void (^)(NSString *))failure
{
    NSString*urlStr = [NSString stringWithFormat:@"%@%@",BASE_URL,GET_SONG_BY_CATEGORY];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (![Util isConnectNetwork]) {
        NSData *offlineData = [[DatabaseManager defaultDatabaseManager] getOfflineData:NoneScreenType subScreenType:SubCategoryDetails subId:0 subsubId:[categoryId integerValue] forPage:page];
        
        [ModelManager handleGetOfflineData:offlineData screenType:NoneScreenType
                             subScreenType:SubCategoryDetails WithSuccess:^(NSMutableArray *arr) {
                                 success(arr);
                             } failure:^(NSString *failureString) {
                                 failure(nil);
                             }];
    }
    else{
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        __weak ASIFormDataRequest *request_ = request;
        [request setTimeOutSeconds:20];
        [request setPostValue:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
        [request setPostValue:categoryId forKey:@"categoryId"];
        [request setCompletionBlock:^{
            
            NSError *e = nil;
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"CUONG: responseData: %@", jsonDic);
            //            NSString *responseData = [[NSString alloc] initWithData:[request_ responseData] encoding:NSUTF8StringEncoding];
            
            if (!jsonDic) {
                NSLog(@"Error parsing JSON: %@", e);
                if(failure)
                    failure(nil);
            } else {
                if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
                {
                    NSArray *dicArr = jsonDic[@"data"];
                    NSMutableArray *songArr = [self parseSongFromDicArr:dicArr];
                    
                    [[DatabaseManager defaultDatabaseManager] storeOffline:NoneScreenType subScreenType:SubCategoryDetails subId:0 subsubId:[categoryId integerValue] forPage:page data:[request_ responseData]];
                    
                    success(songArr);
                }
                else if(failure)
                    failure(nil);
            }
        }];
        [request setFailedBlock:^{
            
            NSError *error = [request_ error];
            if (error.code == ASIRequestTimedOutErrorType){
                [Util showMessage:@"No Network" withTitle:nil];
                [Util showMessage:@"No Network" withTitle:nil];
                if(failure)
                    failure(@"No Network");
            }
            else{
                if(failure)
                    failure(nil);
            }
        }];
        [request startAsynchronous];
    }
}

// MARK:- SubSeries
+(void)getListSongByAlbumId:(NSString *)albumId
                       page:(int)page
                WithSuccess:(void (^)(NSMutableArray *))success
                    failure:(void (^)(NSString *))failure
{
    NSString*urlStr = [NSString stringWithFormat:@"%@%@",BASE_URL,GET_SONG_BY_ALBUM];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (![Util isConnectNetwork]) {
        NSData *offlineData = [[DatabaseManager defaultDatabaseManager] getOfflineData:NoneScreenType subScreenType:SubSeries subId:[albumId integerValue] subsubId:0 forPage:page];
        
        [ModelManager handleGetOfflineData:offlineData screenType:NoneScreenType
                             subScreenType:SubSeries WithSuccess:^(NSMutableArray *arr) {
                                 success(arr);
                             } failure:^(NSString *failureString) {
                                 failure(nil);
                             }];
    }
    else{
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        __weak ASIFormDataRequest *request_ = request;
        [request setTimeOutSeconds:20];
        
        [request setPostValue:albumId forKey:@"albumId"];
        [request setPostValue:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
        [request setCompletionBlock:^{
            
            NSError *e = nil;
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:NSJSONReadingMutableContainers error:&e];
            //            NSString *responseData = [[NSString alloc] initWithData:[request_ responseData] encoding:NSUTF8StringEncoding];
            
            if (!jsonDic) {
                NSLog(@"Error parsing JSON: %@", e);
                if(failure)
                    failure(nil);
            } else {
                if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
                {
                    NSArray *dicArr = jsonDic[@"data"];
                    NSMutableArray *songArr = [self parseSongFromDicArr:dicArr];
                    [[DatabaseManager defaultDatabaseManager] storeOffline:NoneScreenType subScreenType:SubSeries subId:[albumId integerValue] subsubId:0 forPage:page data:[request_ responseData]];
                    success(songArr);
                }
                else if(failure)
                    failure(nil);
            }
        }];
        [request setFailedBlock:^{
            
            NSError *error = [request_ error];
            if (error.code == ASIRequestTimedOutErrorType){
                [Util showMessage:@"No Network" withTitle:nil];
                if(failure)
                    failure(@"No Network");
            }
            else{
                if(failure)
                    failure(nil);
            }
            
        }];
        [request startAsynchronous];
    }
}

+(void)searchSongBykey:(NSString *)key
                  page:(int)page
           WithSuccess:(void (^)(NSMutableArray *))success
               failure:(void (^)(NSString *))failure
{
    NSString*urlStr = [NSString stringWithFormat:@"%@%@",BASE_URL,SEARCH_SONG];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (![Util isConnectNetwork]) {
        failure(nil);
    }
    else{
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        __weak ASIFormDataRequest *request_ = request;
        [request setTimeOutSeconds:20];
        
        [request setPostValue:key forKey:@"song"];
        [request setPostValue:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
        [request setCompletionBlock:^{
            
            NSError *e = nil;
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:NSJSONReadingMutableContainers error:&e];
            //            NSString *responseData = [[NSString alloc] initWithData:[request_ responseData] encoding:NSUTF8StringEncoding];
            
            if (!jsonDic) {
                NSLog(@"Error parsing JSON: %@", e);
                if(failure)
                    failure(nil);
            } else {
                if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
                {
                    NSArray *dicArr = jsonDic[@"data"];
                    NSLog(@"%@", dicArr);
                    NSMutableArray *songArr = [self parseSongFromDicArrSearch:dicArr];
                    success(songArr);
                }
                else if(failure)
                    failure(nil);
            }
        }];
        [request setFailedBlock:^{
            
            NSError *error = [request_ error];
            if (error.code == ASIRequestTimedOutErrorType){
                [Util showMessage:@"No Network" withTitle:nil];
                if(failure)
                    failure(@"No Network");
            }
            else{
                if(failure)
                    failure(nil);
            }
        }];
        [request startAsynchronous];
    }
}




#pragma mark -------------------------------------------------------------------------------------------------------------------------------------
#pragma mark GET ALBUM
#pragma mark -------------------------------------------------------------------------------------------------------------------------------------
// MARK:- Series
+(void)getListAlbumWithPage:(int) page andSuccess:(void (^)(NSMutableArray *))success
                    failure:(void (^)(NSString *))failure
{
    NSString*urlStr = [NSString stringWithFormat:@"%@%@?page=%d",BASE_URL,GET_ALBUM, page];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (![Util isConnectNetwork]) {
        NSData *offlineData = [[DatabaseManager defaultDatabaseManager] getOfflineData:Series subScreenType:None subId:0 subsubId:0 forPage:page];
        
        [ModelManager handleGetOfflineData:offlineData screenType:Series
                             subScreenType:None WithSuccess:^(NSMutableArray *arr) {
                                 success(arr);
                             } failure:^(NSString *failureString) {
                                 failure(nil);
                             }];
    }
    else{
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        __weak ASIFormDataRequest *request_ = request;
        [request setTimeOutSeconds:20];
        
        
        [request setCompletionBlock:^{
            
            NSError *e = nil;
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:NSJSONReadingMutableContainers error:&e];
            //            NSString *responseData = [[NSString alloc] initWithData:[request_ responseData] encoding:NSUTF8StringEncoding];
            
            if (!jsonDic) {
                NSLog(@"Error parsing JSON: %@", e);
                if(failure)
                    failure(nil);
            } else {
                if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
                {
                    NSLog(@"%@",jsonDic);
                    NSArray *dicArr = jsonDic[@"data"];
                    NSMutableArray *songArr = [self parseAlbumFromDicArr:dicArr];
                    [[DatabaseManager defaultDatabaseManager] storeOffline:Series subScreenType:None subId:0 subsubId:0 forPage:page data:[request_ responseData]];
                    success(songArr);
                }
                else if(failure)
                    failure(nil);
            }
        }];
        [request setFailedBlock:^{
            
            NSError *error = [request_ error];
            if (error.code == ASIRequestTimedOutErrorType){
                [Util showMessage:@"No Network" withTitle:nil];
                if(failure)
                    failure(@"No Network");
            }
            else{
                if(failure)
                    failure(nil);
            }
        }];
        [request startAsynchronous];
    }
}
+(Album *)parseAlbumFromDic:(NSDictionary *)dic{
    Album *s = [[Album alloc]init];
    s.albumId = [Validator getSafeString:dic[@"id"]];
    s.name = [Validator getSafeString:dic[@"name"]];
    s.image = [[Validator getSafeString:dic[@"image"]] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    s.numberSong = [Validator getSafeString:dic[@"numberSong"]];
    s.categoryId = [Validator getSafeString:dic[@"category_id"]];
    s.createdDate = [Validator getSafeString:dic[@"createdDate"]];
    s.status = [Validator getSafeString:dic[@"status"]];
    return s;
}
+(NSMutableArray *)parseAlbumFromDicArr:(NSArray *)dicArr{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in dicArr) {
        Album *u = [[Album alloc]init];
        u = [self parseAlbumFromDic:dic];
        [result addObject:u];
    }
    return result;
}



#pragma mark -------------------------------------------------------------------------------------------------------------------------------------
#pragma mark GET CATEGORY
#pragma mark -----------------------------------------------------------------------------------------------------------------------------------


+(void)getListCategoryWithSuccess:(void (^)(NSMutableArray *))success
                          failure:(void (^)(NSString *))failure
{
    NSString*urlStr = [NSString stringWithFormat:@"%@%@",BASE_URL,GET_CATEGORIES];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (![Util isConnectNetwork]) {
        failure(nil);
    }
    else{
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        __weak ASIFormDataRequest *request_ = request;
        [request setTimeOutSeconds:20];
        
        
        [request setCompletionBlock:^{
            
            NSError *e = nil;
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:NSJSONReadingMutableContainers error:&e];
            //            NSString *responseData = [[NSString alloc] initWithData:[request_ responseData] encoding:NSUTF8StringEncoding];
            
            if (!jsonDic) {
                NSLog(@"Error parsing JSON: %@", e);
                if(failure)
                    failure(nil);
            } else {
                if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
                {
                    NSArray *dicArr = jsonDic[@"data"];
                    NSMutableArray *songArr = [self parseCategoryFromDicArr:dicArr];
                    success(songArr);
                }
                else if(failure)
                    failure(nil);
            }
        }];
        [request setFailedBlock:^{
            
            NSError *error = [request_ error];
            if (error.code == ASIRequestTimedOutErrorType){
                [Util showMessage:@"No Network" withTitle:nil];
                if(failure)
                    failure(@"No Network");
            }
            else{
                if(failure)
                    failure(nil);
            }
        }];
        [request startAsynchronous];
    }
}


+ (void)handleGetOfflineData:(NSData*)offlineData screenType:(ScreenType)screenType
               subScreenType:(SubScreenType)subScreenType WithSuccess:(void (^)(NSMutableArray *))success
                     failure:(void (^)(NSString *))failure{
    if (offlineData != nil){
        NSError *e = nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:offlineData options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"%@",offlineData);
        
        if (!jsonDic) {
            NSLog(@"Error parsing JSON: %@", e);
            if(failure)
                failure(nil);
        } else {
            if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
            {
                NSLog(@"%@",jsonDic);
                NSArray *dicArr = jsonDic[@"data"];
                
                NSMutableArray *audioArr = [NSMutableArray new];
                //All SubScreens - Level 2-3
                if (screenType == NoneScreenType) {
                    
                    if (subScreenType == None) {
                        
                    }else if (subScreenType == SubCategory) {
                        audioArr = [self newParseCategoryFromDicArr:dicArr];
                    }else if (subScreenType == SubSeries) {
                        audioArr = [self parseSongFromDicArr:dicArr];
                    }else if (subScreenType == SubCategoryDetails) {
                        audioArr = [self parseSongFromDicArr:dicArr];
                    }else{
                        
                    }
                    
                    //First Screens - Level 1
                }else{
                    
                    if (screenType == Favorite) {
                        audioArr = [self parseSongFromDicArr:dicArr];
                    }else if (screenType == Latest) {
                        audioArr = [self parseSongFromDicArr:dicArr];
                    }else if (screenType == Series) {
                        audioArr = [self parseAlbumFromDicArr:dicArr];
                    }else if (screenType == CategoriesScreen) {
                        audioArr = [self newParseCategoryFromDicArr:dicArr];
                    }else{
                        
                    }
                    
                }
                
                success(audioArr);
            }
            else if(failure)
                failure(nil);
        }
    }else{
        failure(nil);
    }
    
}

// MARK:- Categories
+(void)getListCategoryWithPage:(NSInteger)thePage WithSuccess:(void (^)(NSMutableArray *))success
                       failure:(void (^)(NSString *))failure
{
    NSString*urlStr = [NSString stringWithFormat:@"%@%@?page=%ld",BASE_URL,GET_CATEGORIES, thePage];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (![Util isConnectNetwork]) {
        
        NSData *offlineData = [[DatabaseManager defaultDatabaseManager] getOfflineData:CategoriesScreen subScreenType:None subId:0 subsubId:0 forPage:thePage];
        
        [ModelManager handleGetOfflineData:offlineData screenType:CategoriesScreen
                             subScreenType:None WithSuccess:^(NSMutableArray *arr) {
                                 success(arr);
                             } failure:^(NSString *failureString) {
                                 failure(nil);
                             }];
        
        //        NSData *offlineData = [[DatabaseManager defaultDatabaseManager] getOfflineData:CategoriesScreen forPage:thePage];
        
    }
    else{
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        __weak ASIFormDataRequest *request_ = request;
        [request setTimeOutSeconds:20];
        
        
        [request setCompletionBlock:^{
            
            NSError *e = nil;
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:NSJSONReadingMutableContainers error:&e];
            //            NSString *responseData = [[NSString alloc] initWithData:[request_ responseData] encoding:NSUTF8StringEncoding];
            
            if (!jsonDic) {
                NSLog(@"Error parsing JSON: %@", e);
                if(failure)
                    failure(nil);
            } else {
                if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
                {
                    NSLog(@"%@",jsonDic);
                    NSArray *dicArr = jsonDic[@"data"];
                    NSMutableArray *songArr = [self newParseCategoryFromDicArr:dicArr];
                    [[DatabaseManager defaultDatabaseManager] storeOffline:CategoriesScreen subScreenType:None subId:0 subsubId:0 forPage:thePage data:[request_ responseData]];
                    success(songArr);
                }
                else if(failure)
                    failure(nil);
            }
        }];
        [request setFailedBlock:^{
            
            NSError *error = [request_ error];
            if (error.code == ASIRequestTimedOutErrorType){
                [Util showMessage:@"No Network" withTitle:nil];
                if(failure)
                    failure(@"No Network");
            }
            else{
                if(failure)
                    failure(nil);
            }
        }];
        [request startAsynchronous];
        
    }
    
    
    
}

// MARK:- SubCategory
+(void)getSubCategoryWithCategory:(Categories *)category andPage:(NSInteger)thePage
                       andSuccess:(void (^)(NSMutableArray *))success
                          failure:(void (^)(NSString *))failure
{
    NSString*urlStr = [NSString stringWithFormat:@"%@%@?page=%ld&categoryId=%@",BASE_URL,GET_SUB_CATEGORY, thePage,category.categoryId];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (![Util isConnectNetwork]) {
        NSData *offlineData = [[DatabaseManager defaultDatabaseManager] getOfflineData:NoneScreenType subScreenType:SubCategory subId:[category.categoryId integerValue] subsubId:0 forPage:thePage];
        
        [ModelManager handleGetOfflineData:offlineData screenType:NoneScreenType
                             subScreenType:SubCategory WithSuccess:^(NSMutableArray *arr) {
                                 success(arr);
                             } failure:^(NSString *failureString) {
                                 failure(nil);
                             }];
    }else{
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        __weak ASIFormDataRequest *request_ = request;
        [request setTimeOutSeconds:20];
        
        [request setPostValue:category.categoryId forKey:@"parentId"];
        [request setCompletionBlock:^{
            
            NSError *e = nil;
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:NSJSONReadingMutableContainers error:&e];
            //            NSString *responseData = [[NSString alloc] initWithData:[request_ responseData] encoding:NSUTF8StringEncoding];
            
            if (!jsonDic) {
                NSLog(@"Error parsing JSON: %@", e);
                if(failure)
                    failure(nil);
            } else {
                NSLog(@"%@",jsonDic);
                if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
                {
                    NSArray *dicArr = jsonDic[@"data"];
                    NSMutableArray *songArr = [self newParseCategoryFromDicArr:dicArr];
                    [[DatabaseManager defaultDatabaseManager] storeOffline:NoneScreenType subScreenType:SubCategory subId:[category.categoryId integerValue] subsubId:0 forPage:thePage data:[request_ responseData]];
                    success(songArr);
                }
                else if(failure)
                    failure(nil);
            }
        }];
        [request setFailedBlock:^{
            
            NSError *error = [request_ error];
            if (error.code == ASIRequestTimedOutErrorType){
                [Util showMessage:@"No Network" withTitle:nil];
                if(failure)
                    failure(@"No Network");
            }
            else{
                if(failure)
                    failure(nil);
            }
        }];
        [request startAsynchronous];
    }
}
+(Categories *)parseCategoryFromDic:(NSDictionary *)dic{
    Categories *s = [[Categories alloc]init];
    s.categoryId = [Validator getSafeString:dic[@"id"]];
    s.name = [Validator getSafeString:dic[@"name"]];
    s.image = [[Validator getSafeString:dic[@"image"]] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    s.status = [Validator getSafeString:dic[@"status"]];
    s.isParent = [Validator getSafeString:dic[@"isParent"]];
    s.parentId = [Validator getSafeString:dic[@"parentId"]];
    return s;
}
+(NSMutableArray *)parseCategoryFromDicArr:(NSArray *)dicArr{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in dicArr) {
        Categories *u = [[Categories alloc]init];
        u = [self parseCategoryFromDic:dic];
        [result addObject:u];
        
    }
    return result;
}

+(Categories *)newParseCategoryFromDic:(NSDictionary *)dic{
    Categories *s = [[Categories alloc]init];
    s.categoryId = [Validator getSafeString:dic[@"id"]];
    s.name = [Validator getSafeString:dic[@"name"]];
    s.image = [[Validator getSafeString:dic[@"image"]] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    s.status = [Validator getSafeString:dic[@"status"]];
    s.isParent = [Validator getSafeString:dic[@"isParent"]];
    s.parentId = [Validator getSafeString:dic[@"parentId"]];
    s.countSub = [Validator getSafeInt:dic[@"countSub"]];
    s.level = [Validator getSafeInt:dic[@"level"]];
    
    return s;
}
+(NSMutableArray *)newParseCategoryFromDicArr:(NSArray *)dicArr{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in dicArr) {
        Categories *u = [[Categories alloc]init];
        u = [self newParseCategoryFromDic:dic];
        [result addObject:u];
        
    }
    return result;
}

+(void)registerDevice:(NSString*)deviceID WithBlock:(APIClientCompletionBlock)block{
    [Util setObject:deviceID forKey:@"DeviceToken"];
    
    NSString *bodyString = [NSString stringWithFormat:DEVICE_REGISTER,[deviceID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [deviceID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_URL,bodyString];
    [self backgroundAfnetWorkingStringURL:urlString withBlock:block];
}

+(void)backgroundAfnetWorkingStringURL:(NSString*)stringURL withBlock:(void (^)(ResponseObject *))block{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:stringURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        ResponseObject *responseObj = [[ResponseObject alloc] init];
        
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (httpResponse.statusCode == 200) {
                
                NSLog(@"response :%@", responseObject);
                responseObj.data = responseObject;
                
            }
        }else{
            responseObj.error = error;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(responseObj);
            [SVProgressHUD dismiss];
        });
        
    }];
    [dataTask resume];
    
}

+(void)afnetWorkingStringURL:(NSString*)stringURL withBlock:(void (^)(ResponseObject *))block{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:stringURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD show];
    });
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        ResponseObject *responseObj = [[ResponseObject alloc] init];
        
        NSLog(@"error :%@, response: %@", error, response);
        
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (httpResponse.statusCode == 200) {
                
                NSLog(@"response :%@", responseObject);
                responseObj.data = responseObject;
                
            }
        }else{
            responseObj.error = error;
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                
                if (error.code == -1009 || error.code == -1004 || error.code == -1003 || error.code == -1005) {
                    NSLog(@"The Internet connection appears to be offline.");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Để sử dụng app cần có mạng internet" delegate:nil cancelButtonTitle:@"Huỷ" otherButtonTitles: nil];
                    [alert show];
                    
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Huỷ" otherButtonTitles: nil];
                    [alert show];
                }
                
                return ;
                
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            block(responseObj);
        });
        
    }];
    [dataTask resume];
    
}

+(void)getBannerWithType:(NSString*)type WithSuccess:(void (^)(NSMutableArray *))success
                 failure:(void (^)(NSString *))failure
{
    NSString*urlStr = [NSString stringWithFormat:@"%@%@?type=%@",BASE_URL,BANNNER, type];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (![Util isConnectNetwork]) {
        failure(nil);
    }
    else{
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        __weak ASIFormDataRequest *request_ = request;
        [request setTimeOutSeconds:20];
        
        
        [request setCompletionBlock:^{
            
            NSError *e = nil;
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:NSJSONReadingMutableContainers error:&e];
            //            NSString *responseData = [[NSString alloc] initWithData:[request_ responseData] encoding:NSUTF8StringEncoding];
            
            if (!jsonDic) {
                NSLog(@"Error parsing JSON: %@", e);
                if(failure)
                    failure(nil);
            } else {
                if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
                {
                    NSLog(@"banner : %@",jsonDic);
                    NSArray *arr = jsonDic[@"data"];
                    
                    NSMutableArray *result = [[NSMutableArray alloc]init];
                    for (NSDictionary *dic in arr) {
                        BannerItem *b = [[BannerItem alloc]init];
                        b.bannerURL = dic[@"url"];
                        b.bannerImage = dic[@"image"];
                        b.bannerTitle = dic[@"title"];
                        
                        [result addObject:b];
                        
                    }
                    
                    success(result);
                    
                }
                else if(failure)
                    failure(nil);
            }
        }];
        [request setFailedBlock:^{
            
            NSError *error = [request_ error];
            if (error.code == ASIRequestTimedOutErrorType){
                [Util showMessage:@"No Network" withTitle:nil];
                if(failure)
                    failure(@"No Network");
            }
            else{
                if(failure)
                    failure(nil);
            }
        }];
        [request startAsynchronous];
    }
}


+(void)getListRadioWithSuccess:(void (^)(RadioItem *))success
                       failure:(void (^)(NSString *))failure
{
    NSString*urlStr = [NSString stringWithFormat:@"%@%@",BASE_URL,RADIO];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (![Util isConnectNetwork]) {
        failure(nil);
    }
    else{
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        __weak ASIFormDataRequest *request_ = request;
        [request setTimeOutSeconds:20];
        
        
        [request setCompletionBlock:^{
            
            NSError *e = nil;
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:NSJSONReadingMutableContainers error:&e];
            //            NSString *responseData = [[NSString alloc] initWithData:[request_ responseData] encoding:NSUTF8StringEncoding];
            
            if (!jsonDic) {
                NSLog(@"Error parsing JSON: %@", e);
                if(failure)
                    failure(nil);
            } else {
                if([jsonDic[@"status"] isEqualToString:@"SUCCESS"])
                {
                    NSLog(@"radio : %@",jsonDic);
                    NSDictionary *dic = jsonDic[@"data"];
                    
                    RadioItem *b = [[RadioItem alloc]init];
                    b.radioId = dic[@"id"];
                    b.radioName = dic[@"name"];
                    b.radioLink = dic[@"link"];
                    //                    b.radioMirlx = dic[@"mixlr"];
                    //                    b.radioType = dic[@"type"];
                    b.radioStatus = dic[@"status"];
                    
                    
                    success(b);
                    
                }
                else if(failure)
                    failure(nil);
            }
        }];
        [request setFailedBlock:^{
            
            NSError *error = [request_ error];
            if (error.code == ASIRequestTimedOutErrorType){
                [Util showMessage:@"No Network" withTitle:nil];
                if(failure)
                    failure(@"No Network");
            }
            else{
                if(failure)
                    failure(nil);
            }
        }];
        [request startAsynchronous];
    }
}


@end
