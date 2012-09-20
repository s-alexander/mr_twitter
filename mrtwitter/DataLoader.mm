//
//  DataLoader.mm
//  spectrum
//
//  Created by Alexander on 9/17/11.
//  Copyright 2012 Aleksandr Sergeev. All rights reserved.
//

#import "DataLoader.h"

#import <unistd.h>

@implementation DataLoader
@synthesize url, action, delegate, userData, path,file;

-(void) dealloc {
	[self setUrl:0];
	[self setDelegate:0];
	[self setUserData:0];
  [self setFile:0];
  [self setPath:0];
	[super dealloc];
}

-(void) doRequestImpl {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
	NSData * data = [NSData dataWithContentsOfURL:url];
	[self performSelectorOnMainThread:@selector(done:) withObject:data waitUntilDone:YES];
	[pool release];
}

-(void) done:(NSData *) data {
	[[self delegate] performSelector:[self action] withObject:data withObject:[self userData]];
  if ([self path]) {
    [[NSFileManager defaultManager] removeItemAtPath:[self path] error:0];
  }
}

-(void) request:(NetApiRequest *) request failedWithError:(NSError *) error {
	[self done:0];
	[self autorelease];
}

-(void) request:(NetApiRequest *) request receivedData:(NSData *) data {
  // Fake data for tests
//  data = [@"<h1>fake html data</h1>" dataUsingEncoding:NSUTF8StringEncoding];
//  data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"]];
  
  if ([self path]) {
    if (file)  { 
      [file seekToEndOfFile];
      [file writeData:data]; 
    }
  } else {
    [self done:data];
  }
}

-(void) requestFinished:(NetApiRequest *)request {
  if (file) {
    if ([file seekToEndOfFile] != 0) {
      [[self delegate] performSelector:[self action] withObject:[self path] withObject:[self userData]];
    } else {
      [self done:0];
    }
    [file closeFile];
    [self setFile:0];

  }
  [self autorelease];
}

-(void) requestCanceled:(NetApiRequest *) request {
	[self done:0];
	[self autorelease];
}

-(void) performRequest {
	NetApiRequest * apiRequest = [[[NetApiRequest alloc]init]autorelease];
	[apiRequest setUseCache:NO];
  if ([self path]) {
    [apiRequest setChunksAllow:YES];
  }
	[apiRequest setUrl:[self url]];
	[apiRequest setDelegate:self];
	[apiRequest start];
}

+(void) loadDataInBackgroundFromUrl:(NSURL *) url delegate:(NSObject *) delegate action:(SEL) action userData:(NSObject *) userData {
	DataLoader * loader = [[DataLoader alloc] init];
	[loader setDelegate:delegate];
	[loader setUserData:userData];
	[loader setUrl:url];
	[loader setAction:action];
	[loader performRequest];
}

+(void) writeDataInBackgroundFromUrl:(NSURL *) url toFile:(NSString *)path delegate:(NSObject *) delegate action:(SEL) action userData:(NSObject *) userData {
  
  
	DataLoader * loader = [[DataLoader alloc] init];
  [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
  [loader setFile:[NSFileHandle fileHandleForUpdatingAtPath:path]];
  

	[loader setDelegate:delegate];
	[loader setUserData:userData];
	[loader setUrl:url];
	[loader setAction:action];
  [loader setPath:path];
	[loader performRequest];
  
}
@end
