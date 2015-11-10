//
//  floatTableViewCell.m
//  floatingButtonTrial
//
//  Created by Giridhar on 26/03/15.
//  Copyright (c) 2015 Giridhar. All rights reserved.
//

#import "floatTableViewCell.h"

@implementation floatTableViewCell
@synthesize imgView, title,overlay;

- (void)awakeFromNib
{
    // Initialization code
    overlay = [UIView new];
    overlay.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.6];
    [title addSubview:overlay];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.transform = CGAffineTransformMakeRotation(-M_PI);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
