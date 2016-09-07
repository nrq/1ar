//
//  DatabaseManager.h
//  PTMusicApp
//
//  Created by hieu nguyen on 12/27/14.
//  Copyright (c) 2014 Fruity Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Song.h"
#import "AppEnums.h"

@interface DatabaseManager : NSObject{
    sqlite3_stmt  *stmt;
    
}
+ (DatabaseManager *)defaultDatabaseManager;

-(void)insertPlaylist:(NSString *)name;

-(void)insertSong:(Song *)entity
      andPlaylist:(NSString *)playlist;

-(void)downloadSong:(Song *)entity;
-(NSMutableArray *)getDownloadedSongwithID:(NSString*)idSong;
-(void)deleteDownloadedSongWithSongId:(NSString *)songID;

-(void)insertSong:(Song *)entity
      ToPlaylist:(NSString *)playlist;
-(void)deletePlaylist;

-(NSMutableArray *)getAllPlaylist;
-(NSMutableArray *)getAllSongwithPlaylist:(NSString *)name;

-(void)activePlaylist:(NSString *)name;
-(void)deletePlaylistwithName:(NSString *)name;
-(void)deleteSongListPlaywithName:(NSString *)name;
-(void)deleteAllSongsOfPlaylistWithName: (NSString *)name;
-(void)removeSongWith:(NSString *)songName
          andPlaylist:(NSString *)playlist;
-(NSMutableArray *)getSongwithID:(NSString*)idSong Playlist:(NSString *)namePlaylist;
-(NSMutableArray *)getPlaylistWithName:(NSString*)name;


/*
 screenType     - used for offline storing first screen data
 subScreenType  - used for offline storing second screen data
 subId          - first screen unique id
 subsubId       - second screen unique id , Used only in subcategorydetails
 forPage        -  page number
 data           - data to store
 */
-(void)storeOffline:(ScreenType)screenType
      subScreenType:(SubScreenType)subScreenType
              subId:(NSInteger)subId
           subsubId:(NSInteger)subsubId
            forPage:(NSInteger)page
               data:(NSData *)data;

-(NSData *)getOfflineData:(ScreenType)screenType
            subScreenType:(SubScreenType)subScreenType
                    subId:(NSInteger)subId
                 subsubId:(NSInteger)subsubId
                  forPage:(NSInteger)page;
@end
