//
//  ThreadsHelper.m
// Pocket 4.0
//
//  Created by Abdoelrhman eaita on 8/4/15.
//  Copyright (c) 2015 Abblications. All rights reserved.
//

/** CStyle routines that simplify common threads operations */
#import <Foundation/Foundation.h>
/** Runs the passed block in the main ui queue */
void runInUiThread(void (^block) (void));

/** Runs the passed block in the global background queue */
void runInBackground(void (^backgroundBlock) (void));

void runInBackgroundWithCompletionHandler(void (^backgroundBlock) (void), void (^uiThreadCompletionHandler) (void));
