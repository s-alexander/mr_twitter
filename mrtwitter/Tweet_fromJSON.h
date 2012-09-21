//
//  Tweet_fromJSON.h
//  mrtwitter
//
//  Created by Александр Сергеев on 9/20/12.
//  Copyright (c) 2012 Alexander Sergeev. All rights reserved.
//

#import "Tweet.h"
#import "MRTwitterDataManager.h"

@interface Tweet (fromJSON)

+(NSArray *) getRecentTweetsFromJSON:(NSArray *) json withDataManager:(MRTwitterDataManager *)dataManager;
@end
