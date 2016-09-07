//
//  ResponseObject.h
//  MyKuliahApps
//
//  Created by tuan vn on 11/26/15.
//  Copyright © 2015 tuanvn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseObject : NSObject

@property (nonatomic, strong) id data;
//@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) BOOL isLoadFromLocal;

@end
