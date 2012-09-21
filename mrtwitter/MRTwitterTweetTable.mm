//
//  MRTwitterTweetTable.m
//  mrtwitter
//
//  Created by Александр Сергеев on 9/20/12.
//  Copyright (c) 2012 Alexander Sergeev. All rights reserved.
//

#import "MRTwitterTweetTable.h"
#import "MRPublicTweetsManager.h"
#import "Tweet.h"
#import "FileStore+MRTwitter.h"

@interface MRTwitterTweetTable ()

@end

@implementation MRTwitterTweetTable

@synthesize tableView, activityIndicator;

-(MRPublicTweetsManager *) tweetManager {
  return [MRPublicTweetsManager sharedMRPublicTweetsManager];
}

-(void) doAutoUpdate {
//  [[self tweetManager] update];
  NSLog(@"Update");
}

-(void) scheduleAutoupdate {
  NSTimeInterval updateInterval = 61;

  NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(doAutoUpdate) userInfo:0 repeats:NO];
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)viewDidLoad
{
  
  [[self tweetManager] setDelegate:self];
  [self doAutoUpdate];

  [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) freeAutoupdateTimer {
  [_autoupdater invalidate];
  [_autoupdater release];
  _autoupdater = 0;
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  [self setTableView:0];
  [self setActivityIndicator:0];
  [self freeAutoupdateTimer];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
  return [[self tweetManager]tweetsCount];
}

-(Tweet *) tweetForIndexPath:(NSIndexPath *)path {
  Tweet * t = [[[self tweetManager]allTweets] objectAtIndex:[path row]];
  return t;
}

-(void) imageData:(NSData *) data forCell:(UITableViewCell *) cell {
  [[cell imageView] setImage:[UIImage imageWithData:data]];
}

-(NSIndexPath *) pathForTweet:(Tweet *) t {
  NSUInteger pos = [[[self tweetManager] allTweets] indexOfObject:t];
  if (NSNotFound != pos) {
    return [NSIndexPath indexPathForRow:pos inSection:0];
  }
  return 0;
}

-(void) imageData:(NSData *) data forTweet:(Tweet *) tweet {
  NSIndexPath * path = [self pathForTweet:tweet];
  [[self tableView] beginUpdates];
  [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
  [[self tableView] endUpdates];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (0 == cell) {
    cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier]autorelease];
  }
  Tweet * t = [self tweetForIndexPath:indexPath];
//  NSLog(@"%@", [t avatar_url]);
  [[cell detailTextLabel] setText:[t body]];
  [[cell textLabel] setText:[t author]];
  
  
  NSURL * avatarUrl = [NSURL URLWithString:[t avatar_url]];
  [[cell imageView] setImage:0];
  [[FileStore twitterAvatars] loadDataInBackgroundFromUrl:avatarUrl delegate:self actionLoad:@selector(imageData:forTweet:) userData:t actionCache:@selector(imageData:forCell:) userData:cell];    
  // Configure the cell...
    
  return cell;
}

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  [self scheduleAutoupdate];
}

-(void) tweetsManager:(MRPublicTweetsManager *) manager failedToUpdate:(NSError *) error {
  UIAlertView * alert = [[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]autorelease];
  [alert show];
}

-(void) tweetsManager:(MRPublicTweetsManager *) manager updatedWithTweets:(NSArray *) tweets {
  if ([tweets count] > 0) {
    NSMutableArray * paths = [[[NSMutableArray alloc]initWithCapacity:[tweets count]]autorelease];
    for (size_t i = 0; i < [tweets count]; ++i) {
      [paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationLeft];
    [tableView endUpdates];
  }
  [self scheduleAutoupdate];
}

-(void) tweetsManager:(MRPublicTweetsManager *) manager fullReloadWithTweets:(NSArray *) tweets {
  [[self tableView] reloadData];
}

-(void) tweetsManagerDidEndUpdate:(MRPublicTweetsManager *) manager {
  [[self tableView] setContentInset:UIEdgeInsetsZero];
  [[self activityIndicator] stopAnimating];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
/*  const CGFloat dragThreshold = 44;
  const CGFloat topGap = 53;
  if (scrollView.contentOffset.y < -dragThreshold) {
    [[self tweetManager] update];
    [[self activityIndicator] startAnimating];
    [[self tableView] setContentInset:UIEdgeInsetsMake(topGap, 0, 0, 0)];
  }*/
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

-(void) dealloc {
  [self setActivityIndicator:0];
  [self setTableView:0];
  [self freeAutoupdateTimer];
  [super dealloc];
}

@end
