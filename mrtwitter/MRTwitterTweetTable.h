//
//  MRTwitterTweetTable.h
//  mrtwitter
//
//  Created by Александр Сергеев on 9/20/12.
//  Copyright (c) 2012 Alexander Sergeev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRPublicTweetsManager.h"
@interface MRTwitterTweetTable : UIViewController <MRPublicTweetsManagerDelegate, UIScrollViewDelegate, UIAlertViewDelegate> {

}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicator;
@end
