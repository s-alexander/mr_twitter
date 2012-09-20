//
//  NetApiRequest.h
//  spectrum
//
//  Created by Alexander on 8/14/11.
//  Copyright 2012 Aleksandr Sergeev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetApiRequestDelegate.h"

@interface NetApiRequest : NSObject {
	NSURLConnection * _connection;
	NSMutableData * _data;
}

@property (nonatomic, assign) NSObject<NetApiRequestDelegate> * delegate;
@property (nonatomic, copy) NSURL * url;
@property (nonatomic, assign) BOOL useCache;
@property (nonatomic, assign) BOOL chunksAllow;
-(void) start;
-(void) cancel;
@end
