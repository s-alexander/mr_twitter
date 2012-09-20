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


+(Tweet *) tweetWithId:(NSNumber *)tid fromDataManager:(MRTwitterDataManager *)dataManager {
  return [[dataManager selectFrom:@"Tweet" usingPredicate:[NSPredicate predicateWithFormat:@"tweet_id == %llu", [tid longLongValue]]] firstObject];
  
}

+(NSDictionary *) json2Tweet:(NSDictionary *)json {
  NSString * username = [[json objectForKey:@"user"] objectForKey:@"screen_name"];
  return [NSDictionary dictionaryWithObjectsAndKeys:
          [json objectForKey:@"text"], @"body",
          username, @"author",
          [[json objectForKey:@"user"] objectForKey:@"profile_image_url"], @"avatar_url",
          [json objectForKey:@"id"], @"tweet_id",
          nil];
}

+(NSArray *) newTweetsFromJSON:(NSArray *) json withDataManager:(MRTwitterDataManager *)dataManager {
  NSMutableArray * result = 0;
  for (NSDictionary * tweetData in json) {
    NSNumber * tweetId = [tweetData objectForKey:@"id"];
    NSLog(@"id = %llu", [tweetId longLongValue]);
    Tweet * old = [self tweetWithId:tweetId fromDataManager:dataManager];
    if (0 == old) {
      Tweet * newTweet = (Tweet *)[dataManager insertInto:@"Tweet" withData:[self json2Tweet:tweetData]];
      [lazy_aiar(&result) addObject:newTweet];
    }
  }
  return result;
}

@end
