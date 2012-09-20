//
//  NetApiRequest.mm
//  spectrum
//
//  Created by Alexander on 8/14/11.
//  Copyright 2012 Aleksandr Sergeev. All rights reserved.
//

#import "NetApiRequest.h"


@implementation NetApiRequest

@synthesize delegate, url, useCache, chunksAllow;

-(void) free {
	[_connection release];
	_connection = 0;
	[_data release];
	_data = 0;
}

-(void) start {
	if (!_connection) {
		NSURLRequest * request = [[[NSURLRequest alloc] initWithURL:[self url] cachePolicy:([self useCache] ? NSURLRequestReturnCacheDataElseLoad:NSURLRequestUseProtocolCachePolicy) timeoutInterval:60]autorelease];
		_connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES];
		_data = [[NSMutableData alloc] init];
	}
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
  if ([self useCache]) {
    NSLog(@"Caching %@", [cachedResponse description]);
    return cachedResponse;
  }
  return nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[[self delegate] request:self failedWithError:error];
	[self free];
}

-(void) cancel {
	[_connection cancel];
	[[self delegate] requestCanceled:self];
	[self setDelegate:0];
	[self free];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  if ([self chunksAllow]) {
    [[self delegate] request:self receivedData:data];
  } else {
    [_data appendData:data];
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  if (![self chunksAllow]) {
    [[self delegate] request:self receivedData:_data];
  }
  [[self delegate] requestFinished:self];
	[self free];
}

@end
