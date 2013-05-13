//
//  EnvelopeCell.m
//  WeightandBalance
//
//  Created by Adam on 4/30/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "EnvelopeCell.h"
#import "EnvelopePoint.h"
#import "Aircraft.h"

@implementation EnvelopeCell
@synthesize ep;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [[self weightLabel] setText:[NSString stringWithFormat:@"%1.1f",[[ep weight]floatValue]]];
    [[self armLabel] setText:[NSString stringWithFormat:@"%1.1f",[[ep arm] floatValue]]];
    [[self weightWarning] setHidden:([[ep weight]floatValue]<=[[self maxGross] floatValue])];
    
}

@end
