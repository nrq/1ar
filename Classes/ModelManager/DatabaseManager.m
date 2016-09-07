//
//  DatabaseManager.m
//  PTMusicApp
//
//  Created by hieu nguyen on 12/27/14.
//  Copyright (c) 2014 Fruity Solution. All rights reserved.
//

#import "DatabaseManager.h"
#import "Song.h"
#import "Util.h"

@implementation DatabaseManager


static DatabaseManager        *sharedObject = nil;

+ (DatabaseManager *)defaultDatabaseManager{
    if (sharedObject == nil) {
        @synchronized(self){
            if (sharedObject == nil) {
                sharedObject = [[DatabaseManager alloc] init];
            }
        }
    }
    return sharedObject;
}

- (NSString *)getDBPath {
    // Get path of database.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"PTMusicApp.sqlite"];
}

-(void)insertPlaylist:(NSString *)name
{
    sqlite3 *database;
    NSString *dbPath = [self getDBPath];
    NSString *playListName =[name stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *compiledStatement = nil;
        
        NSString *sqlQuery = [NSString stringWithFormat:@"insert into playlist (name,isActive) values ('%@',1)",playListName];
        
        if(sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(database));
            }
        }
        
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
}

-(void)activePlaylist:(NSString *)name{
    sqlite3 *database;
    NSString *dbPath = [self getDBPath];
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *compiledStatement = nil;
        
        NSString *sqlQuery = [NSString stringWithFormat:@"update playlist Set isActive = 1 Where name='%@'",name];
        if(sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(database));
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    [self deletePlaylist];
}

-(void)deletePlaylistwithName:(NSString *)name
{
    sqlite3 *database;
    NSString *dbPath = [self getDBPath];
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *compiledStatement = nil;
        
        NSString *sqlQuery = [NSString stringWithFormat:@"DELETE from detail WHERE playlist = '%@'",name];

        if(sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &compiledStatement, nil) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(database));
                
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
}

-(void)deleteSongListPlaywithName:(NSString *)name{
    sqlite3 *database;
    NSString *dbPath = [self getDBPath];
    [Util removeObjectForKey:@"errorDelete"];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *compiledStatement = nil;
        
        NSString *sqlQuery = [NSString stringWithFormat:@"DELETE from playlist Where name ='%@' and isActive= 1 ",name];
        
        if(sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &compiledStatement, nil) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(database));
                [Util setObject:[NSString stringWithFormat:@"%s",sqlite3_errmsg(database)] forKey:@"errorDelete"];
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
}

-(void)deleteAllSongsOfPlaylistWithName: (NSString *)name{
    sqlite3 *database;
    NSString *dbPath = [self getDBPath];
    [Util removeObjectForKey:@"errorDelete"];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *compiledStatement = nil;
        
        NSString *sqlQuery = [NSString stringWithFormat:@"DELETE from detail Where playlist ='%@'",name];
        
        if(sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &compiledStatement, nil) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(database));
                [Util setObject:[NSString stringWithFormat:@"%s",sqlite3_errmsg(database)] forKey:@"errorDelete"];
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
}

-(void)deletePlaylist
{
    sqlite3 *database;
    NSString *dbPath = [self getDBPath];
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *compiledStatement = nil;
        
        NSString *sqlQuery = [NSString stringWithFormat:@"DELETE from playlist WHERE isActive = 0"];

        if(sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &compiledStatement, nil) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(database));

            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    
}

-(void)insertSong:(Song *)entity
      andPlaylist:(NSString *)playlist

{
    
    sqlite3 *database;
    NSString *dbPath = [self getDBPath];
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *compiledStatement = nil;
        NSString *lyric = [entity.lyrics stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSLog(@"%@",entity.downloadNum);
        NSString *sqlQuery = [NSString stringWithFormat:@"insert into detail (id, playlist , name , lyrics , link , singer_name , album_id , category_id, downloaded, viewed, image ) values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')", entity.songId, playlist ,entity.name,lyric, entity.link,entity.singerName,entity.albumId,entity.categoryId, entity.downloadNum, entity.viewNum,entity.image];
        if(sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(database));
                
            }
        }
        
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
 
}

-(void)downloadSong:(Song *)entity {
    
    sqlite3 *database;
    NSString *dbPath = [self getDBPath];
    
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        //-------
        char *err;
        NSString *sql=[NSString stringWithFormat:@" CREATE TABLE IF NOT EXISTS 'download'(`id`	TEXT,`playlist`	TEXT,`name`	TEXT,`lyrics`	TEXT,`link`	TEXT,`singer_name`	TEXT,`album_id`	TEXT,`category_id`	TEXT,`number`	TEXT,`hot`	TEXT,`news`	TEXT,`downloaded`	VARCHAR(40),`viewed`	VARCHAR(40),`image`	TEXT,`desc`	TEXT)"];
        
        if(sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) !=SQLITE_OK)
        {
            sqlite3_close(database);
            NSAssert(0, @"Table failed to create");
        }
        //------
        
        
        sqlite3_stmt *compiledStatement = nil;
        NSString *lyric = [entity.lyrics stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSLog(@"%@",entity.downloadNum);
        NSString *sqlQuery = [NSString stringWithFormat:@"insert into download (id , name , lyrics , link , singer_name , album_id , category_id, downloaded, viewed, image, desc ) values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')", entity.songId ,entity.name,lyric, entity.link,entity.singerName,entity.albumId,entity.categoryId, entity.downloadNum, entity.viewNum,entity.image,entity.desc];
        if(sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(database));
                
            }
        }
        
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
    
}

-(void)removeSongWith:(NSString *)songID
      andPlaylist:(NSString *)playlist

{
    sqlite3 *database;
    NSString *dbPath = [self getDBPath];
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *compiledStatement = nil;
        NSString *playListName =[playlist stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        
        NSString *sqlQuery = [NSString stringWithFormat:@"delete from detail where id = '%@'", songID];
        if(sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(database));
                
            }
        }
        
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
    
}

//SongListPlay
-(void)insertSong:(Song *)entity
       ToPlaylist:(NSString *)playlist{
    sqlite3 *database;
    NSString *dbPath = [self getDBPath];
    [Util removeObjectForKey:@"errorsql"];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *compiledStatement = nil;
        NSString *lyrics =[entity.lyrics stringByReplacingOccurrencesOfString:@"'" withString:@"\""] ;
        NSString *name =[entity.name stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSString *singerName =[entity.singerName stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSString *playListName =[playlist stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        
        NSString *sqlQuery = [NSString stringWithFormat:@"insert into detail (id, playlist , name , lyrics , link , singer_name , album_id , category_id, downloaded, viewed, image ) values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')", [NSString stringWithFormat:@"%@_%@", entity.songId, playListName], playListName ,name,lyrics, entity.link,singerName,entity.albumId,entity.categoryId, entity.downloadNum, entity.viewNum];
        if(sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(database));
                [Util setObject:[NSString stringWithFormat:@"%s",sqlite3_errmsg(database)] forKey:@"errorsql"];
            }
        }
        
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
}

-(NSMutableArray *)getAllPlaylist
{
    
    sqlite3 *database;
    NSString *dbPath = [self getDBPath];
    NSMutableArray *content = [[NSMutableArray alloc]init];
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        sqlite3_stmt *selectStatement;
        NSString *selectSql = [NSString stringWithFormat:@"select * from playlist"];
        
        if (sqlite3_prepare_v2(database, [selectSql UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectStatement) == SQLITE_ROW){
                
                if ((const char*)sqlite3_column_text(selectStatement, 1)) {
                    NSString *name = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(selectStatement, 1)];
                    NSString *playListName =[name stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
                        [content addObject:playListName];
                    
                }

            }
        }
        sqlite3_finalize(selectStatement);
        
    }
    sqlite3_close(database);
    return content;
    
}


-(NSMutableArray *)getAllSongwithPlaylist:(NSString *)name
{
    NSMutableArray *arrr = [[NSMutableArray alloc] init];
    
    sqlite3 *database;
    
    NSString *dbPath = [self getDBPath];

    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        sqlite3_stmt *selectStatement;
        NSString *playListName =[name stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSString *selectSql = [NSString stringWithFormat:@"select * from detail where playlist = '%@'",playListName];
        
        if (sqlite3_prepare_v2(database, [selectSql UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectStatement) == SQLITE_ROW){
                
                Song *s = [[Song alloc]init];
                s.songId = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 0) encoding:NSUTF8StringEncoding];
                // id should be <song id>_<playlist name>
                NSArray* splitBy_ = [s.songId componentsSeparatedByString: @"_"];
                if ([splitBy_ count] > 0)
                    s.songId = [splitBy_ objectAtIndex:0];
                
                
                s.name = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 2) encoding:NSUTF8StringEncoding];
                s.lyrics = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 3) encoding:NSUTF8StringEncoding];
                s.singerName = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 5) encoding:NSUTF8StringEncoding];
                s.link = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 4) encoding:NSUTF8StringEncoding];
                s.downloadNum = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 11) encoding:NSUTF8StringEncoding];
                s.viewNum = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 12) encoding:NSUTF8StringEncoding];
                s.image = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 13) encoding:NSUTF8StringEncoding];

                s.lyrics =[s.lyrics stringByReplacingOccurrencesOfString:@"\"" withString:@"'"] ;
                s.name =[s.name stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
                s.singerName =[s.singerName stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
                NSLog(@"id: %@, name playlisr: %@", s.songId,playListName);
                
                [arrr addObject:s];

            }
        }
        sqlite3_finalize(selectStatement);
        
    }
    sqlite3_close(database);
    return arrr;
}

-(NSMutableArray *)getSongwithID:(NSString*)idSong Playlist:(NSString *)namePlaylist
{
    NSMutableArray *arrr = [[NSMutableArray alloc] init];
    
    sqlite3 *database;
    
    NSString *dbPath = [self getDBPath];
    
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        sqlite3_stmt *selectStatement;
        NSString *playListName =[namePlaylist stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSString *selectSql = [NSString stringWithFormat:@"select * from detail where playlist = '%@' and id = '%@'",playListName,idSong];
        
        if (sqlite3_prepare_v2(database, [selectSql UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectStatement) == SQLITE_ROW){
                
                Song *s = [[Song alloc]init];
                s.songId = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 0) encoding:NSUTF8StringEncoding];
                // id should be <song id>_<playlist name>
                NSArray* splitBy_ = [s.songId componentsSeparatedByString: @"_"];
                if ([splitBy_ count] > 0)
                    s.songId = [splitBy_ objectAtIndex:0];
                
                
                s.name = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 2) encoding:NSUTF8StringEncoding];
                s.lyrics = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 3) encoding:NSUTF8StringEncoding];
                s.singerName = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 5) encoding:NSUTF8StringEncoding];
                s.link = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 4) encoding:NSUTF8StringEncoding];
                s.downloadNum = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 11) encoding:NSUTF8StringEncoding];
                s.viewNum = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 12) encoding:NSUTF8StringEncoding];
                
                s.lyrics =[s.lyrics stringByReplacingOccurrencesOfString:@"\"" withString:@"'"] ;
                s.name =[s.name stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
                s.singerName =[s.singerName stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
                
                
                [arrr addObject:s];
                
            }
        }
        sqlite3_finalize(selectStatement);
        
    }
    sqlite3_close(database);
    return arrr;
}

/*
 Return all downloaded audio if idSong is nil, else return song for specific idSond.(Can be nil)
 */
-(NSMutableArray *)getDownloadedSongwithID:(NSString*)idSong {
    NSMutableArray *arrr = [[NSMutableArray alloc] init];
    
    sqlite3 *database;
    
    NSString *dbPath = [self getDBPath];
    
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        sqlite3_stmt *selectStatement;
        
        NSString *selectSql = nil;
        
        //Get all songs
        if (idSong == nil){
            selectSql = [NSString stringWithFormat:@"select * from download"];
            //Get only sonds with songId
        }else{
            selectSql = [NSString stringWithFormat:@"select * from download where id = '%@'",idSong];
        }
        
        if (sqlite3_prepare_v2(database, [selectSql UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectStatement) == SQLITE_ROW){
                
                Song *s = [[Song alloc]init];
                s.songId = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 0) encoding:NSUTF8StringEncoding];
                // id should be <song id>_<playlist name>
                NSArray* splitBy_ = [s.songId componentsSeparatedByString: @"_"];
                if ([splitBy_ count] > 0)
                    s.songId = [splitBy_ objectAtIndex:0];
                
                
                s.name = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 2) encoding:NSUTF8StringEncoding];
                s.lyrics = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 3) encoding:NSUTF8StringEncoding];
                s.singerName = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 5) encoding:NSUTF8StringEncoding];
                s.link = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 4) encoding:NSUTF8StringEncoding];
                s.downloadNum = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 11) encoding:NSUTF8StringEncoding];
                s.viewNum = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 12) encoding:NSUTF8StringEncoding];
                s.image = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 13) encoding:NSUTF8StringEncoding];
                s.desc = [NSString stringWithCString:(char *)sqlite3_column_text(selectStatement, 14) encoding:NSUTF8StringEncoding];
                
                s.lyrics =[s.lyrics stringByReplacingOccurrencesOfString:@"\"" withString:@"'"] ;
                s.name =[s.name stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
                s.singerName =[s.singerName stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
                
                
                [arrr addObject:s];
                
            }
        }
        sqlite3_finalize(selectStatement);
        
    }
    sqlite3_close(database);
    return arrr;
}

/*
 Delete downloaded song
 */
-(void)deleteDownloadedSongWithSongId:(NSString *)songID {
    sqlite3 *database;
    NSString *dbPath = [self getDBPath];
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *compiledStatement = nil;
        
        NSString *sqlQuery = [NSString stringWithFormat:@"delete from download where id = '%@'", songID];
        if(sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(database));
                
            }
        }
        
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
    
}


-(NSMutableArray *)getPlaylistWithName:(NSString*)name
{
    
    sqlite3 *database;
    NSString *dbPath = [self getDBPath];
    NSMutableArray *content = [[NSMutableArray alloc]init];;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        sqlite3_stmt *selectStatement;
        NSString *selectSql = [NSString stringWithFormat:@"select * from playlist where name = '%@'",name];
        
        if (sqlite3_prepare_v2(database, [selectSql UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectStatement) == SQLITE_ROW){
                
                if ((const char*)sqlite3_column_text(selectStatement, 1)) {
                    NSString *name = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(selectStatement, 1)];
                    NSString *playListName =[name stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
                    [content addObject:playListName];
                    
                }
                
            }
        }
        sqlite3_finalize(selectStatement);
        
    }
    sqlite3_close(database);
    return content;
    
}


//------------------------------------------------
//MARK:- Offline data
//------------------------------------------------

-(void)storeOffline:(ScreenType)screenType
      subScreenType:(SubScreenType)subScreenType
              subId:(NSInteger)subId
           subsubId:(NSInteger)subsubId
            forPage:(NSInteger)page
               data:(NSData *)data{
    sqlite3 *database;
    NSString *dbPath = [self getDBPath];
    [Util removeObjectForKey:@"errorsql"];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        
        sqlite3_stmt *compiledStatement = nil;
//        NSString *lyrics =[entity.lyrics stringByReplacingOccurrencesOfString:@"'" withString:@"\""] ;
        
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSString *sqlQuery = [NSString new];
        
        if (subScreenType == None){
            //-------
            char *err;
            NSString *sql=[NSString stringWithFormat:@" CREATE TABLE IF NOT EXISTS '%@'(page INTEGER,`data` TEXT)",[AppEnums nameOfScreenType:screenType]];
            
            if(sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) !=SQLITE_OK)
            {
                sqlite3_close(database);
                NSAssert(0, @"Table failed to create");
            }
            //------
            
            sqlQuery = [NSString stringWithFormat:@"insert or replace into %@ (page, data) values('%tu','%@')",[AppEnums nameOfScreenType:screenType],page,dataString];
            
            
            
        }else if (subScreenType == SubCategoryDetails){
            
            //-------
            char *err;
            NSString *sql=[NSString stringWithFormat:@" CREATE TABLE IF NOT EXISTS '%@'(id TEXT PRIMARY KEY,'%@' INTEGER,page INTEGER,`data` TEXT)",[AppEnums nameOfSubScreenType:subScreenType],[AppEnums nameOfId:subScreenType]];
            
            if(sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) !=SQLITE_OK)
            {
                sqlite3_close(database);
                NSAssert(0, @"Table failed to create");
            }
            //------
            
            
            sqlQuery = [NSString stringWithFormat:@"insert or replace into %@ (id, %@ , page, data) values('%@','%tu','%tu','%@')",[AppEnums nameOfSubScreenType:subScreenType],[AppEnums nameOfId:subScreenType],[NSString stringWithFormat:@"%tu%tu",subsubId,page],subsubId,page,dataString];
            
            
            
        }else{
            
            //-------
            char *err;
            NSString *sql=[NSString stringWithFormat:@" CREATE TABLE IF NOT EXISTS '%@'(id TEXT PRIMARY KEY,'%@' INTEGER,page INTEGER,`data` TEXT)",[AppEnums nameOfSubScreenType:subScreenType],[AppEnums nameOfId:subScreenType]];
            
            if(sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) !=SQLITE_OK)
            {
                sqlite3_close(database);
                NSAssert(0, @"Table failed to create");
            }
            //------
            
            
            sqlQuery = [NSString stringWithFormat:@"insert or replace into %@ (id, %@ , page, data) values('%@','%tu','%tu','%@')",[AppEnums nameOfSubScreenType:subScreenType], [AppEnums nameOfId:subScreenType],[NSString stringWithFormat:@"%tu%tu",subId,page],subId,page,dataString];
        }
        
        if(sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(database));
                [Util setObject:[NSString stringWithFormat:@"%s",sqlite3_errmsg(database)] forKey:@"errorsql"];
            }
        }else{
            NSLog(@"%s",sqlite3_errmsg(database));
        }
        
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
}

-(NSData *)getOfflineData:(ScreenType)screenType
            subScreenType:(SubScreenType)subScreenType
                    subId:(NSInteger)subId
                 subsubId:(NSInteger)subsubId
                  forPage:(NSInteger)page{
    NSData *decodedData = [[NSData alloc] init];
    
    sqlite3 *database;
    
    NSString *dbPath = [self getDBPath];
    
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        sqlite3_stmt *selectStatement;
//        NSString *playListName =[namePlaylist stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        
//        NSString *sqlQuery = [NSString stringWithFormat:@"insert or replace into %@ (page, json) values('%tu','%@')",[AppEnums nameOfScreenType:screenType],page,json];
        
//        NSString *selectSql = [NSString stringWithFormat:@"select * from %@ where page = '%tu'",[AppEnums nameOfScreenType:screenType],page];
        
        NSString *sqlQuery = [NSString new];
        
        //Leve 1
        if (subScreenType == None){
            sqlQuery = [NSString stringWithFormat:@"select * from %@ where page = '%tu'",[AppEnums nameOfScreenType:screenType],page];
            
        //Leve 3
        }else if (subScreenType == SubCategoryDetails){
            sqlQuery = [NSString stringWithFormat:@"select * from %@ where subcategoryid = '%tu' and page = '%tu'",[AppEnums nameOfSubScreenType:subScreenType],subsubId,page];
            
        //Leve 2
        }else{
            sqlQuery = [NSString stringWithFormat:@"select * from %@ where %@ = '%tu' and page = '%tu'",[AppEnums nameOfSubScreenType:subScreenType],[AppEnums nameOfId:subScreenType],subId,page];
        }
        
        
        if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &selectStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectStatement) == SQLITE_ROW){
                
                if ((const char*)sqlite3_column_text(selectStatement, 1)) {
                    int dataColumn = 1;
                    
                    
                    if (subScreenType == SubCategory || subScreenType == SubCategoryDetails || subScreenType == SubSeries){
                        dataColumn = 3;
                    }
                    
                    NSString *encodedString = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(selectStatement, dataColumn)];
                    
                    decodedData = [encodedString dataUsingEncoding:NSUTF8StringEncoding];
                }
                
            }
        }else{
            NSLog(@"%s",sqlite3_errmsg(database));
        }
        sqlite3_finalize(selectStatement);
        
    }
    sqlite3_close(database);
    return decodedData;
}


@end
