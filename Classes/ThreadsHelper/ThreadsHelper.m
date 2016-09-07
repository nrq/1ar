//
//  ThreadsHelper.m
// Pocket 4.0
//
//  Created by Abdoelrhman eaita on 8/4/15.
//  Copyright (c) 2015 Abblications. All rights reserved.
//

#import "ThreadsHelper.h"


void runInUiThread(void (^block) (void)){
    dispatch_async(dispatch_get_main_queue(), block);
}

void runInBackground(void (^backgroundBlock) (void))
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        backgroundBlock();
    });
}

void runInBackgroundWithCompletionHandler(void (^backgroundBlock) (void), void (^uiThreadCompletionHandler) (void))
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        backgroundBlock();
        runInUiThread(uiThreadCompletionHandler);
    });
}
