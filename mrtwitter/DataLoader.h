//
//  DataLoader.h
//  spectrum
//
//  Created by Alexander on 9/17/11.
//  Copyright 2012 Aleksandr Sergeev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetApiRequest.h"

// Load data in background thread
@interface DataLoader : NSObject <NetApiRequestDelegate> {

}

@property (nonatomic, retain) NSObject * delegate;
@property (nonatomic, retain) NSObject * userData;
@property (nonatomic, assign) SEL action;
@property (nonatomic, retain) NSURL * url;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSFileHandle * file;

-(void) performRequest;

+(void) loadDataInBackgroundFromUrl:(NSURL *) url delegate:(NSObject *) delegate action:(SEL) action userData:(NSObject *) userData;

+(void) writeDataInBackgroundFromUrl:(NSURL *) url toFile:(NSString *)path delegate:(NSObject *) delegate action:(SEL) action userData:(NSObject *) userData;

@end
