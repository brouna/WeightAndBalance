//
//  AircraftLoadViewController.h
//  WeightandBalance
//
//  Created by Adam on 4/28/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Aircraft;
@class EnvelopeGraph;

@interface AircraftLoadViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) Aircraft *aircraft;

@property (weak, nonatomic) IBOutlet UITextField *frontRowLeftLabel;
@property (weak, nonatomic) IBOutlet UITextField *frontRowRightLabel;
@property (weak, nonatomic) IBOutlet UITextField *secondRowLeftLabel;
@property (weak, nonatomic) IBOutlet UITextField *secondRowRightLabel;
@property (weak, nonatomic) IBOutlet UITextField *baggage;
@property (weak, nonatomic) IBOutlet UITextField *fuelQty;
@property (weak, nonatomic) IBOutlet UILabel *inTotalLimitsLabel;
@property (weak, nonatomic) IBOutlet UILabel *bagErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *fuelErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *envelopeLimitsLabel;
@property (weak, nonatomic) IBOutlet UIView *graphView;
@property (strong, nonatomic) IBOutlet EnvelopeGraph *graphInset;
@property (weak, nonatomic) IBOutlet UISwitch *tksSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *o2Switch;
@property (weak, nonatomic) IBOutlet UILabel *TKSLabel;
@property (weak, nonatomic) IBOutlet UILabel *o2Label;

- (IBAction)backgroundTapped :(id)sender;
- (IBAction)updateSwitches;
- (IBAction)mailLoading;


@end

