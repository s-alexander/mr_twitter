//
//  NetApiRequestDelegate.h
//  spectrum
//
//  Created by Alexander on 8/14/11.
//  Copyright 2012 Aleksandr Sergeev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NetApiRequest;

@protocol NetApiRequestDelegate
@required
-(void) request:(NetApiRequest *) request failedWithError:(NSError *) error;
-(void) request:(NetApiRequest *) request receivedData:(NSData *) data;
-(void) requestCanceled:(NetApiRequest *) request;
-(void) requestFinished:(NetApiRequest *) request;
@end
