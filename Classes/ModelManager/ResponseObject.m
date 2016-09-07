//
//  ResponseObject.m
//  MyKuliahApps
//
//  Created by tuan vn on 11/26/15.
//  Copyright © 2015 tuanvn. All rights reserved.
//

#import "ResponseObject.h"

@implementation ResponseObject

-(NSString *)description{
    return [NSString stringWithFormat:@"data: %@, error: %@", self.data, self.error];
}

@end
