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

-(BOOL) isUpdating {
  return _isUpdating;
}

-(BOOL) update {
  if (_isUpdating) {
    return NO;
  }
  _isUpdating = YES;
  [[self dataManager] countIn:@"Tweet" usingPredicate:0];
  NSMutableURLRequest * request = [[[NSMutableURLRequest alloc]initWithURL:[self pubStreamURL]]autorelease];
  NSURLConnection * connection = [[[NSURLConnection alloc]initWithRequest:request delegate:self]autorelease];
  [connection start];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  return YES;
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

-(void) endUpdate {
  _isUpdating = NO;
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  [[self delegate] tweetsManagerDidEndUpdate:self];
  
}

-(void) proccedError:(NSError *) error {
  [[self delegate] tweetsManager:self failedToUpdate:error];
  [self endUpdate];
}

-(void) proccedResponse:(NSData *) data {
//  NSLog(@"Data = %@", [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]autorelease]);
  NSError * error = 0;
  NSDictionary * jsonDict = [NSDictionary dictionaryWithJSONData:data error:&error];
  NSArray * tweetsData = safe_cast<NSArray>(jsonDict);
  if (0 != error || 0 == tweetsData) {
    if (0 == error) {
      NSString * errorDesct = [safe_cast<NSDictionary>(jsonDict) objectForKey:@"error"];
      error = [NSError errorWithDomain:@"" code:0 userInfo:[NSDictionary dictionaryWithObject:(errorDesct ? errorDesct : @"Internal twitter error") forKey:NSLocalizedDescriptionKey]];
    }
    [self proccedError:error];
  } else {
   // NSLog(@"Tweets: [%@]", tweetsData);
    NSArray * newTweets = [Tweet getRecentTweetsFromJSON:tweetsData withDataManager:[self dataManager]];
    if ([newTweets count]) {
      NSIndexSet * indxs = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [newTweets count])];
      [_tweetsCache insertObjects:newTweets atIndexes:indxs];
    }
    // MERGE?
    //    const BOOL fullReload = [newTweets count] == [tweetsData count];
    const BOOL fullReload = false;
    
    if (fullReload) {
      [[self delegate] tweetsManager:self fullReloadWithTweets:newTweets];
    } else {
      [[self delegate] tweetsManager:self updatedWithTweets:newTweets];
    }
    [self endUpdate];
    [[self dataManager]save];
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

@end
