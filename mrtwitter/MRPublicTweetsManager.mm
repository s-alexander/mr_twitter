//
//  MRTweetManager.m
//  mrtwitter
//
//  Created by Александр Сергеев on 9/20/12.
//  Copyright (c) 2012 Alexander Sergeev. All rights reserved.
//

#import "MRPublicTweetsManager.h"
#import "NSDictionary_JSONExtensions.h"
#import "safe_cast.h"
#import "Tweet_fromJSON.h"
#import "MRTwitterDataManager.h"

@implementation MRPublicTweetsManager

@synthesize delegate;

+(MRPublicTweetsManager *) loadMRPublicTweetsManager {
  MRPublicTweetsManager * result = [[[MRPublicTweetsManager alloc]init]autorelease];
  return result;
}

+(MRPublicTweetsManager *) sharedMRPublicTweetsManager {
  static MRPublicTweetsManager * result = [[self loadMRPublicTweetsManager] retain];
  return result;
}

-(MRTwitterDataManager *) dataManager {
  return [MRTwitterDataManager sharedMRTwitterDataManager];
}

-(NSURL *) pubStreamURL {
//  return [NSURL URLWithString:@"http://alxsrg.com/public_timeline.json"];
  return [NSURL URLWithString:@"http://api.twitter.com/1/statuses/public_timeline.json"];
//  return [NSURL URLWithString:@"https://stream.twitter.com/1/statuses/sample.json"];
}

-(NSString *) username {
  return @"";
}

-(NSString *) password {
  return @"";
}

-(void) update {
  [[self dataManager] countIn:@"Tweet" usingPredicate:0];
  NSMutableURLRequest * request = [[[NSMutableURLRequest alloc]initWithURL:[self pubStreamURL]]autorelease];
  NSURLConnection * connection = [[[NSURLConnection alloc]initWithRequest:request delegate:self]autorelease];
  [connection start];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void) populateCache {
  _tweetsCache = [[NSMutableArray alloc]initWithArray:[[self dataManager] selectFrom:@"Tweet" usingPredicate:0 sortBy:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
}

-(NSArray *) allTweets {
  if ( 0 == _tweetsCache) {
    [self populateCache];
  }
  
  return _tweetsCache;
}

-(NSUInteger) tweetsCount {
  return [[self dataManager] countIn:@"Tweet" usingPredicate:0];
}

-(void) proccedError:(NSError *) error {
  [[self delegate] tweetsManager:self failedToUpdate:error];
  [[self delegate] tweetsManagerDidEndUpdate:self];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void) proccedResponse:(NSData *) data {
  //NSLog(@"Data = %@", [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]autorelease]);
  NSError * error = 0;
  NSArray * tweetsData = safe_cast<NSArray>([NSDictionary dictionaryWithJSONData:data error:&error]);
  if (0 != error) {
    [self proccedError:error];
  } else {
   // NSLog(@"Tweets: [%@]", tweetsData);
    NSArray * newTweets = [Tweet newTweetsFromJSON:tweetsData withDataManager:[self dataManager]];
    if ([newTweets count]) {
      NSIndexSet * indxs = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [newTweets count])];
      [_tweetsCache insertObjects:newTweets atIndexes:indxs];
    }
    //    const BOOL fullReload = [newTweets count] == [tweetsData count];
    const BOOL fullReload = false;
    if (fullReload) {
      [[self delegate] tweetsManager:self fullReloadWithTweets:newTweets];
    } else {
      [[self delegate] tweetsManager:self updatedWithTweets:newTweets];
    }
    [[self delegate] tweetsManagerDidEndUpdate:self];
    [[self dataManager]save];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [self proccedError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [self proccedResponse:_connectionData];
  [_connectionData release];
  _connectionData = 0;
  
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  if (0 == _connectionData) {
    _connectionData = [[NSMutableData alloc]init];
  }
  [_connectionData appendData:data];
}

-(void) connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  if ([challenge previousFailureCount] == 0) {
    NSLog(@"received authentication challenge");
    NSURLCredential *newCredential = [NSURLCredential credentialWithUser:[self username]
                                                                password:[self password]
                                                             persistence:NSURLCredentialPersistenceForSession];
    NSLog(@"credential created");
    [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    NSLog(@"responded to authentication challenge");
  }
  else {
    NSLog(@"previous authentication failure");
  }
}

/*- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
  return 0; // Do not cache
}*/



@end
