//
//  MRPublicTweetsManager.h
//  mrtwitter
//
//  Created by Александр Сергеев on 9/20/12.
//  Copyright (c) 2012 Alexander Sergeev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRPublicTweetsManager;

@protocol MRPublicTweetsManagerDelegate <NSObject>
@required
-(void) tweetsManager:(MRPublicTweetsManager *) manager failedToUpdate:(NSError *) error;
-(void) tweetsManager:(MRPublicTweetsManager *) manager updatedWithTweets:(NSArray *) tweets;
-(void) tweetsManager:(MRPublicTweetsManager *) manager fullReloadWithTweets:(NSArray *) tweets;
-(void) tweetsManagerDidEndUpdate:(MRPublicTweetsManager *) manager;
@end

@interface MRPublicTweetsManager : NSObject <NSURLConnectionDelegate> {
  NSMutableData * _connectionData;
}


-(void) update;
-(NSArray *) allTweets;
-(NSArray *) tweetsInRange:(NSRange)range;
-(NSUInteger) tweetsCount;

@property (nonatomic, retain) id<MRPublicTweetsManagerDelegate> delegate;

+(MRPublicTweetsManager *) sharedMRPublicTweetsManager;


@end
