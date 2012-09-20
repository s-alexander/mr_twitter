//
//  Tweet.h
//  mrtwitter
//
//  Created by Александр Сергеев on 9/20/12.
//  Copyright (c) 2012 Alexander Sergeev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * avatar_url;
@property (nonatomic) int64_t tweet_id;

@end
