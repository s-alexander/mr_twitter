//
//  FileStore.m
//  Talerka
//
//  Created by Alexander on 11/27/11.
//  Copyright (c) 2012 Aleksandr Sergeev. All rights reserved.
//

#import "FileStore.h"
#import "NSArray+FirstObject.h"
#import "DataLoader.h"
#import "GTMNSString+URLArguments.h"
//#import <CommonCrypto/CommonDigest.h>

@interface FileRequestDelegate : NSObject
@property (nonatomic, assign) SEL selector;
@property (nonatomic, retain) NSObject * delegate;
@property (nonatomic, retain) NSObject * userData;

@end

@implementation FileRequestDelegate : NSObject
@synthesize selector, delegate, userData;

-(void) dealloc {
  [self setUserData:0];
  [self setDelegate:0];
  [super dealloc];
}
@end

@interface FileRequest : NSObject
@property (nonatomic, retain) NSURL * url;
@property (nonatomic, retain) NSMutableArray * delegates;
@end

@implementation FileRequest
@synthesize url;
@synthesize delegates;

-(void) dealloc {
  [self setUrl:0];
  [self setDelegates:0];
  [super dealloc];
}
@end


@implementation FileStore
@synthesize maxThreads, writeToFile;

-(NSURL *) localCacheUrlForResource:(NSURL *) resource {
  if (resource) {
    if (NSString * absString = [resource absoluteString]) {
      if ([absString length] > 0) {
        NSString * hashName = [absString gtm_stringByEscapingForURLArgument];
        if (NSString * extension = [resource pathExtension]) {
          return [NSURL fileURLWithPath:[NSString stringWithFormat:
                                         @"%@/%@.%@", _dir, hashName, extension]];
        }
      }
    }
  }
  return 0;
}

-(NSURL *) localUrlForResource:(NSURL *) resource {
  if (resource) {
    if (NSString * absString = [resource absoluteString]) {
      if ([absString length] > 0) {
        NSString * hashName = [absString gtm_stringByEscapingForURLArgument];
        if (NSString * extension = [resource pathExtension]) {
          NSString * bundlePath = [[NSBundle mainBundle] pathForResource:hashName ofType:extension];
          if ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath]) {
            return [NSURL fileURLWithPath:bundlePath];
          }
          return [NSURL fileURLWithPath:[NSString stringWithFormat:
                    @"%@/%@.%@", _dir, hashName, extension]];
        }
      }
    }
  }
  return 0;
}

-(id) initWithName:(NSString *) name {
  self = [super init];
  if (self) {
    _name = [name retain];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
    if (NSString *documentsDirectory = [paths firstObject]) {
      _dir = [[NSString stringWithFormat:@"%@/%@", documentsDirectory, _name] retain];
      _queue = [[NSMutableArray alloc]init];
      _loading = [[NSMutableArray alloc]init];
      _activeThreads = 0;
      BOOL isDir (NO);
      if ([[NSFileManager defaultManager] fileExistsAtPath:_dir isDirectory:&isDir]) {
        // Blah
      } else {
        [[NSFileManager defaultManager] createDirectoryAtPath:_dir withIntermediateDirectories:YES attributes:0 error:0];
      }
    }
  }
  return self;
}

-(void)dealloc {
  [_name release];
  [_dir release];
  [_queue release];
  [super dealloc];
}

+(FileStore *) fileStoreNamed:(NSString *)name {
  return [[[FileStore alloc]initWithName:name]autorelease];
}

-(void) performFileRequest:(FileRequest *) fr path:(NSURL *)path {
  if (_activeThreads < [self maxThreads]) {
    [_loading addObject:fr];
    ++_activeThreads;
    if ([self writeToFile]) {
      [DataLoader writeDataInBackgroundFromUrl:[fr url] toFile:[path path] delegate:self action:@selector(fileReady:userData:) userData:fr];
    } else {
      [DataLoader loadDataInBackgroundFromUrl:[fr url] delegate:self action:@selector(saveData:userData:) userData:fr];
    }
  } else {
    [_queue addObject:fr];
  }
}

-(void) nextRequestImpl {
  --_activeThreads;
  if (FileRequest * nextInQueue = [[[_queue lastObject]retain]autorelease]) {
    [_queue removeLastObject];
    [self performFileRequest:nextInQueue path:[self localUrlForResource:[nextInQueue url]]];
  } else {
    //NSLog(@"No requests in queue");
  }  
}

-(void) nextRequest {
  [self performSelectorOnMainThread:@selector(nextRequestImpl) withObject:0 waitUntilDone:NO];
}

-(void) fileReady:(NSString *)path userData:(FileRequest *) fr {
  [_loading removeObject:fr];
  [self nextRequest];
  for (FileRequestDelegate * frd in [fr delegates]) {
    [[frd delegate] performSelector:[frd selector] withObject:path withObject:[frd userData]];
  }
}

-(void) saveData:(NSData *) data userData:(FileRequest *) fr {
  [_loading removeObject:fr];
  if (data) {
    NSURL * path = [self localUrlForResource:[fr url]];
    [data writeToURL:path atomically:YES];
    //NSLog(@"Saving resource %@ to %@", [[fr url] absoluteString], [path absoluteString]);
  }
  
  [self nextRequest];
  
  for (FileRequestDelegate * frd in [fr delegates]) {
    SEL selector = [frd selector];
    NSObject * delegate = [frd delegate];
    if (delegate && selector) {
      [delegate performSelector:selector withObject:data withObject:[frd userData]];
    }
  }
}

-(BOOL) localFileExistsForUrl:(NSURL *) url {
  if (url) {
    if (NSURL * localUrl = [self localUrlForResource:url]) {
      const BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:[localUrl path]];
      return result;
    }
  }
  return NO;
}

-(void) loadDataInBackgroundFromUrl:(NSURL *) url delegate:(NSObject *) delegate actionLoad:(SEL) actionLoad userData:(NSObject *) userData  actionCache:(SEL) actionCache userData:(NSObject *) userDataCache {
  NSURL * path = [self localUrlForResource:url];
  if (0 == path) {
    [delegate performSelector:actionCache withObject:0 withObject:userDataCache];
    return;
  }
  const BOOL isLoading = [self isLoadingFileForUrl:url];
  if (NO == isLoading && [self writeToFile] && [[NSFileManager defaultManager] fileExistsAtPath:[path path]]) {
//    NSLog(@"File for %@ exists", [url absoluteString]);
    [delegate performSelector:actionCache withObject:[path path] withObject:userDataCache];
    return;
  }
  if (NO == isLoading && ![self writeToFile]) {
    if (NSData * data = [NSData dataWithContentsOfURL:path]) {    
//      NSLog(@"Data for %@ exists", [url absoluteString]);
      [delegate performSelector:actionCache withObject:data withObject:userDataCache];
      return;
    }
  }
  
  //NSLog(@"Downloading resource %@", [url absoluteString]);
  FileRequestDelegate * fld = [[[FileRequestDelegate alloc]init]autorelease];
  [fld setUserData:userData];
  [fld setSelector:actionLoad];
  [fld setDelegate:delegate];
  
  for (FileRequest * fr in _loading) {
    if ([[fr url] isEqual:url]) {
      //NSLog(@"Request for %@ found in loading, appending new delegate", [url absoluteString]);
      [[fr delegates] addObject:fld];
      return;
     }
  }

  for (FileRequest * fr in _queue) {
    if ([[fr url] isEqual:url]) {
     // NSLog(@"Request for %@ found in queue, appending new delegate", [url absoluteString]);
      [[fr delegates] addObject:fld];
      return;
    }
  }

  
  FileRequest * fr = [[[FileRequest alloc]init]autorelease];
  [fr setUrl:url];
  [fr setDelegates:[[[NSMutableArray alloc]initWithObjects:fld, nil]autorelease]];
       

  [self performFileRequest:fr path:path];
}

-(BOOL) isLoadingFileForUrl:(NSURL *) url {
  for (FileRequest * fr in _loading) {
    if ([[fr url] isEqual:url]) {
      return YES;
    }
  }
  for (FileRequest * fr in _queue) {
    if ([[fr url] isEqual:url]) {
      return YES;
    }
  }
  return NO;
}

-(void) loadDataInBackgroundFromUrl:(NSURL *) url delegate:(NSObject *) delegate action:(SEL) action userData:(NSObject *) userData  {
  [self loadDataInBackgroundFromUrl:url delegate:delegate actionLoad:action userData:userData actionCache:action userData:userData];
}

-(void) removeAll {
  NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_dir error:0];
  for (NSString * file in files) {
    NSString * path = [_dir stringByAppendingPathComponent:file];
    [[NSFileManager defaultManager] removeItemAtPath:path error:0]; 
  }
}

-(NSUInteger) size {
  NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_dir error:0];
  NSUInteger size = 0;
  for (NSString * file in files) {
    NSString * path = [_dir stringByAppendingPathComponent:file];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:0];
    if(fileAttributes != nil)
    {
      NSString *fileSize = [fileAttributes objectForKey:NSFileSize];
      size += [fileSize intValue];
    }
  }
  return size;
}

-(NSUInteger) queueSize {
  return [_queue count] + _activeThreads;
}

@end
