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

@interface MRTwitterTweetTable ()

@end

@implementation MRTwitterTweetTable

@synthesize tableView;

-(MRPublicTweetsManager *) tweetManager {
  return [MRPublicTweetsManager sharedMRPublicTweetsManager];
}

- (void)viewDidLoad
{
  
  [[self tweetManager] setDelegate:self];
  [[self tweetManager] update];
  [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (0 == cell) {
    cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier]autorelease];
  }
  Tweet * t = [self tweetForIndexPath:indexPath];
  NSLog(@"%@ %@", [t body], [t author]);
  [[cell detailTextLabel] setText:[t body]];
  [[cell textLabel] setText:[t author]];
  [[cell imageView] setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[t avatar_url]]]]];
    
  // Configure the cell...
    
  return cell;
}

-(void) tweetsManager:(MRPublicTweetsManager *) manager failedToUpdate:(NSError *) error {
  UIAlertView * alert = [[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:0 cancelButtonTitle:@"OK" otherButtonTitles:nil]autorelease];
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
}

-(void) tweetsManager:(MRPublicTweetsManager *) manager fullReloadWithTweets:(NSArray *) tweets {
  [[self tableView] reloadData];
}

-(void) tweetsManagerDidEndUpdate:(MRPublicTweetsManager *) manager {
  [[self tableView] setContentInset:UIEdgeInsetsZero];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
  if (scrollView.contentOffset.y < -44) {
    [[self tweetManager] update];
    [[self tableView]setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
  }
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

@end
