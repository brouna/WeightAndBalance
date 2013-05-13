//
//  EnvelopeViewController.h
//  WeightandBalance
//
//  Created by Adam on 4/30/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Aircraft;
@class EnvelopePoint;
@class EnvelopeGraph;

@interface EnvelopeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *envelope;
@property (strong, nonatomic) NSNumber *maxGross;

@property (weak, nonatomic) IBOutlet UILabel *tableHeaderLabel;
@property (strong, nonatomic) IBOutlet UITableView *envTableView;

@property (strong, nonatomic) IBOutlet UIView *envelopePopoverView;
@property (strong, nonatomic) IBOutlet UIView *envelopePopoverSmallView;
@property (strong, nonatomic) IBOutlet UITextField *popoverWeight;
@property (strong, nonatomic) IBOutlet UITextField *popoverArm;
@property (strong, nonatomic) IBOutlet UIView *graphView;
@property (strong, nonatomic) IBOutlet EnvelopeGraph *graphInset;


- (IBAction)dismissPopover;

@end
