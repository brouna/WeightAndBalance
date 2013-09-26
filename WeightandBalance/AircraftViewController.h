//
//  AircraftViewController.h
//  WeightandBalance
//
//  Created by Adam on 4/27/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Aircraft.h"

@interface AircraftViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic)    Aircraft *aircraft;
@property BOOL createNew;

@property (weak, nonatomic) IBOutlet UITextField *tailLabel;
@property (weak, nonatomic) IBOutlet UITextField *typeLabel;
@property (weak, nonatomic) IBOutlet UITextField *bewWLabel;
@property (weak, nonatomic) IBOutlet UITextField *bewALabel;
@property (weak, nonatomic) IBOutlet UITextField *frontALabel;
@property (weak, nonatomic) IBOutlet UITextField *backALabel;
@property (weak, nonatomic) IBOutlet UITextField *baggageALabel;
@property (weak, nonatomic) IBOutlet UITextField *fuelCLabel;
@property (weak, nonatomic) IBOutlet UITextField *fuelAlabel;
@property (weak, nonatomic) IBOutlet UITextField *mgwLabel;
@property (weak, nonatomic) IBOutlet UITextField *maxBaggageWt;
@property (weak, nonatomic) IBOutlet UITextField *tksWLabel;
@property (weak, nonatomic) IBOutlet UITextField *tksALabel;
@property (weak, nonatomic) IBOutlet UITextField *o2WLabel;
@property (weak, nonatomic) IBOutlet UITextField *o2ALabel;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;


- (IBAction)backgroundTapped:(id)sender;


@end
