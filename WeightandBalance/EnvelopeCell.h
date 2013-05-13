//
//  EnvelopeCell.h
//  WeightandBalance
//
//  Created by Adam on 4/30/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EnvelopePoint;
@class Aircraft;

@interface EnvelopeCell : UITableViewCell

@property (strong, nonatomic) EnvelopePoint *ep;
@property (strong, nonatomic) NSNumber *maxGross;


@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *armLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightWarning;

@end
