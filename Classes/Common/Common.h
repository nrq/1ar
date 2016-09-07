//
//  Common.h
//  PTMusicApp
//
//  Created by hieu nguyen on 12/6/14.
//  Copyright (c) 2014 Fruity Solution. All rights reserved.
//

#ifndef PTMusicApp_Common_h
#define PTMusicApp_Common_h
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define APP_NAME                @"NurulQuran Audio"

#define BASE_URL                @"http://myislamwell.nurulquran.com/index.php/api/"
#define GOODAPP_URL             @"http://projectemplate.com/"
#define GET_ALBUM               @"album"
#define GET_CATEGORIES          @"category"
#define GET_CATEGORIES_NEW      @"category?page=%d"

#define GET_SUB_CATEGORY        @"getSubs"
#define GET_SONGS               @"songView"
#define GET_SONG_BY_CATEGORY    @"songCategory?"
#define GET_SONG_BY_ALBUM       @"songAlbum?"
#define SEARCH_SONG             @"nameSong?"
#define LISTEN_SONG             @"listenSong?"
#define DOWNLOAD_SONG           @"downloadSong"
#define TOP_SONG                @"topSong?"
#define PARAM_ALBUM_ID          @"albumId"
#define PARAM_SONG              @"song"
#define PARAM_CATEGORY_ID       @"categoryId"

#define CURRENT_SONG_ID_KEY     @"CURRENTSONGIDKEY"
#define CURRENT_PLAYLIST        @"curreentPlaylist"

#define BANNNER                 @"banner"
#define RADIO                   @"radio"

#pragma mark TEXT SHOW 

#define SECTION_MUSIC           @"MENU"
#define SECTION_TOOL            @"OTHER"
#define MENU_ALL_SONG           @"Latest"
#define MENU_TOP_SONG           @"Most Favorite"
#define MENU_ALBUM              @"Series"
#define MENU_CATEGORY           @"Categories"
#define MENU_PLAYLIST           @"Playlist"

#define MENU_SEARCH             @"Search"
#define MENU_GOOD_APP           @"Multiply Your Rewards"
#define MENU_RADIO              @"NQ Radio"
#define MENU_MY_DOWNLOAD        @"My Download"
#define MENU_ABOUT              @"About"
#define MENU_LOGOUT             @"Exit app"

#define VIEW_TOP_SONGS          1
#define VIEW_ALL_SONGS          2
#define VIEW_ALBUMS             3
#define VIEW_CATEGORIES         4
#define VIEW_PLAY_LIST          5
#define VIEW_MY_DOWNLOAD        6


#define LANG_REMOVE_PLAYLIST            @"Are you sure you want to remove this playlist?"
#define LANG_REMOVE_SONG_FROM_PLAYLIST  @"Are you sure you want to remove this song from play list?"
#define OFFSET_FOR_KEYBOARD 80.0

#define ADMOB_ID                                @"ca-app-pub-3290535774449331/8454533127"

#define ADMOB_ID                                @"ca-app-pub-3290535774449331/8454533127"

#define ALERT_MOBILE_DATA_OFF                           @"Mobile Data is Turned Off"
#define ALERT_TURN_ON_DATA                              @"Turn on mobile data or user Wi-Fi to access data."
#define ALERT_FILE_DOWNLOADED                           @"The file has been downloaded Successfully."
#define ALERT_FILE_DOWNLOAD_FAILED                      @"Downloading failed."
#define ALERT_TRY_AGAIN                                 @"Please try again."
#define ALERT_ALREADY_DOWNLOADED                        @"The file is already downloaded."
#define ALERT_ALREADY_NO_DOWNLOADED_FILES               @"You have no downloaded files."

#endif
