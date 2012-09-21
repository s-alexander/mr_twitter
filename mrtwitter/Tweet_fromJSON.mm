//
//  Tweet_fromJSON.mm
//  mrtwitter
//
//  Created by Александр Сергеев on 9/20/12.
//  Copyright (c) 2012 Alexander Sergeev. All rights reserved.
//

#import "Tweet.h"
#import "NSArray+FirstObject.h"
#import "lazy_aiar.h"
#import "MRTwitterDataManager.h"

@implementation Tweet (fromJSON)

inline NSObject * notNil(NSObject * o) {
  return o ? o : [NSNull null];
}

+(Tweet *) tweetWithId:(NSNumber *)tid fromDataManager:(MRTwitterDataManager *)dataManager {
  return [[dataManager selectFrom:@"Tweet" usingPredicate:[NSPredicate predicateWithFormat:@"tweet_id == %llu", [tid longLongValue]]] firstObject];
  
}

+(NSDictionary *) json2Tweet:(NSDictionary *)json order:(NSUInteger) order {
  NSString * username = [[json objectForKey:@"user"] objectForKey:@"screen_name"];
  NSLog(@"%@", username);
  return [NSDictionary dictionaryWithObjectsAndKeys:
          notNil([json objectForKey:@"text"]), @"body",
          notNil(username), @"author",
          [NSNumber numberWithUnsignedInteger:order], @"order",
          notNil([[json objectForKey:@"user"] objectForKey:@"profile_image_url"]), @"avatar_url",
          notNil([json objectForKey:@"id"]), @"tweet_id",
          nil];
}

+(NSArray *) newTweetsFromJSON:(NSArray *) json withDataManager:(MRTwitterDataManager *)dataManager {
  NSMutableArray * result = 0;
  for (NSDictionary * tweetData in json) {
    NSNumber * tweetId = [tweetData objectForKey:@"id"];
    Tweet * old = [self tweetWithId:tweetId fromDataManager:dataManager];
    if (0 == old) {
      const NSUInteger order = 1 + [dataManager countIn:@"Tweet" usingPredicate:0];
      NSDictionary * params = [self json2Tweet:tweetData order:order];
      
      Tweet * newTweet = (Tweet *)[dataManager insertInto:@"Tweet" withData:params];
      [lazy_aiar(&result) addObject:newTweet];
    }
  }
  return result;
}

@end
