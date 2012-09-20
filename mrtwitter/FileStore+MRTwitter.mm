//
//  FileStore+MRTwitter.m
//  mrtwitter
//
//  Created by Александр Сергеев on 9/20/12.
//  Copyright (c) 2012 Alexander Sergeev. All rights reserved.
//

#import "FileStore+MRTwitter.h"

@implementation FileStore (MRTwitter)

+(FileStore *) loadTwitterAvatars {
  FileStore * result = [FileStore fileStoreNamed:@"twitter_avatars"];
  [result setMaxThreads:3];
  return result;
}


+(FileStore *) twitterAvatars {
  static FileStore * result = [[self loadTwitterAvatars] retain];
  return result;
}

@end
