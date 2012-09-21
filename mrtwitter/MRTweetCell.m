//
//  MRTweetCell.m
//  mrtwitter
//
//  Created by Александр Сергеев on 9/21/12.
//  Copyright (c) 2012 Alexander Sergeev. All rights reserved.
//

#import "MRTweetCell.h"

@implementation MRTweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
      [[self detailTextLabel] setNumberOfLines:3];
      [[self detailTextLabel] setFont:[UIFont systemFontOfSize:14]];
      [[self textLabel] setFont:[UIFont boldSystemFontOfSize:8]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
