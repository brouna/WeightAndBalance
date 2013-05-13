//
//  envelopeGraph.h
//  WeightandBalance
//
//  Created by Adam on 5/1/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Aircraft.h"
#import "EnvelopePoint.h"

@interface EnvelopeGraph : UIView

@property (strong, nonatomic) NSMutableArray *envelope;
@property (strong, nonatomic) EnvelopePoint *currentLoading;

@end
