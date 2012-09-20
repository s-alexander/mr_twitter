//
//  FileStore.h
//  Talerka
//
//  Created by Alexander on 11/27/11.
//  Copyright (c) 2012 Aleksandr Sergeev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileStore : NSObject {
  NSString * _name;
  NSString * _dir;
  NSMutableArray * _queue;
  NSMutableArray * _loading;
  NSUInteger _activeThreads;
}

-(NSURL *) localUrlForResource:(NSURL *) resource;
-(NSURL *) localCacheUrlForResource:(NSURL *) resource;

-(id) initWithName:(NSString *) name;
+(FileStore *) fileStoreNamed:(NSString *)name;
-(void) loadDataInBackgroundFromUrl:(NSURL *) url delegate:(NSObject *) delegate action:(SEL) action userData:(NSObject *) userData;
-(void) removeAll;
-(NSUInteger) size;
-(BOOL) isLoadingFileForUrl:(NSURL *) url;
-(BOOL) localFileExistsForUrl:(NSURL *) url;
-(void) loadDataInBackgroundFromUrl:(NSURL *) url delegate:(NSObject *) delegate actionLoad:(SEL) actionLoad userData:(NSObject *) userData actionCache:(SEL) actionCache userData:(NSObject *) userData;
@property (nonatomic, assign) NSUInteger maxThreads;
@property (nonatomic, assign) BOOL writeToFile;
-(NSUInteger) queueSize;
@end
